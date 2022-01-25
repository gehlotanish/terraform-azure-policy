# Azure Policy
## Usage

```terraform

locals {

  policy_tags_rule = <<RULE
{
  "if": {
    "allOf": [
      {
        "field": "type",
        "equals": "Microsoft.Compute/virtualMachineScaleSets"
      },
      {
        "not": {
          "field": "[concat('tags[', parameters('tagName'), ']')]",
          "equals": "[parameters('tagValue')]"
        }
      }
    ]
  },
  "then": {
    "effect": "modify",
    "details": {
      "roleDefinitionIds": [
        "/providers/Microsoft.Authorization/roleDefinitions/9980e02c-c2be-4d73-94e8-173b1dc7cf3c"
      ],
      "operations": [
        {
          "operation": "addOrReplace",
          "field": "[concat('tags[', parameters('tagName'), ']')]",
          "value": "[parameters('tagValue')]"
        }
      ]
    }
  }
}
RULE

  policy_tags_parameters = <<PARAMETERS
{
  "tagName": {
    "type": "String",
    "metadata": {
      "displayName": "Tag Name",
      "description": "Name of the tag, such as 'environment'"
    }
  },
  "tagValue": {
    "type": "String",
    "metadata": {
      "displayName": "Tag Value",
      "description": "Value of the tag, such as 'production'"
    }
  }
}
PARAMETERS

  policy_assignments = {
    production = {
      display_name = "VMSS tags checking for my production subscription"
      description  = "VMSS tags checking for my production subscription"
      scope        = "/subscriptions/xxxxx",
      location     = module.azure_region.location
      parameters = jsonencode({
        environment = {
          value = "production"
        },
        managed_by = {
          value = "devops"
        }
      })
      identity_type = "SystemAssigned"
    },
    preproduction = {
      display_name = "VMSS tags checking for my preproduction subscription"
      description  = "VMSS tags checking for my preproduction subscription"
      scope        = "/subscriptions/xxxxx",
      location     = module.azure_region.location
      parameters = jsonencode({
        env = {
          value = "preproduction"
        },
        managed_by = {
          value = "devops"
        }
      })
      identity_type = "None"
    }
  }
}

module "policy_tags" {
  source  = "./policy"

  policy_display_name       = "VMSS tagging policy"

  policy_rule_content       = local.policy_tags_rule
  policy_parameters_content = local.policy_tags_parameters

  policy_assignments        = local.policy_assignments
}

```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| policy\_assignments | Map with maps to configure assignments. Map key is the name of the assignment. | <pre>map(object({<br>    display_name  = string,<br>    description   = string,<br>    scope         = string,<br>    parameters    = string,<br>    identity_type = string,<br>    location      = string,<br>  }))</pre> | n/a | yes |
| policy\_description | The description of the policy definition. | `string` | `""` | no |
| policy\_display\_name | The display name of the policy definition. | `string` | n/a | yes |
| policy\_mgmt\_group\_name | Create the Policy Definition at the Management Group level | `string` | `null` | no |
| policy\_mode | The policy mode that allows you to specify which resource types will be evaluated. The value can be `All`, `Indexed` or `NotSpecified`. | `string` | `"All"` | no |
| policy\_name | The name of the policy definition. Defaults generated from display name | `string` | `""` | no |
| policy\_parameters\_content | Parameters for the policy definition. This field is a json object that allows you to parameterize your policy definition. | `string` | n/a | yes |
| policy\_rule\_content | The policy rule for the policy definition. This is a json object representing the rule that contains an if and a then block. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| policy\_assignment | Azure policy assignments map |
| policy\_definition\_id | Azure policy ID |
