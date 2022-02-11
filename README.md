# Usage

```terraform

data "azurerm_log_analytics_workspace" "example" {
  name                = "logs"
  resource_group_name = "jenkins_group"
}

locals {

  policy_assignments = {
    production = {
      name         = "Vm Monit"
      location     = "eastus2"
      parameters   = jsonencode({
        logAnalytics_1 = {
          value = data.azurerm_log_analytics_workspace.example.id,
        }
      })

    }
  }
}

module "policy_tags" {
  source             = "./policy"
  exist_policy       = "Enable Azure Monitor for VMs"
  policy_assignments = local.policy_assignments
}

```

# azurepolicyvm


1. Data funtion to set policy initiative defination.

```terraform
azurerm_policy_set_definition
```

A data source we are fetching azure existing policy set defination initiative id to create policy assignments. it has a conditional pramaeters depends on boolean variable `custom_policy_enabled`. if it is false then, it will call data source of azurerm_policy_set_definition and we required the resource id.
if the value is true then it will call function `azurerm_policy_definition` i.e we can create a complete custom policy definition. 

* exist_policy: we have to set the existing policy name, `azurerm_policy_set_definition` function will fetch the id of policy definition based on display_name.

```terraform
azurerm_policy_definition
```

2. To create a own custom policy we are using function `azurerm_policy_definition`, this function only run if the value of "cutsom_policy_enabled" is true.

`azurerm_policy_definition`: The policy definitions for the policy set definition. This is a json object representing the bundled policy definitions. Here, we have set necessory values inside the fuction. it manages a policy rule definition on a management group or your provider subscription. it supports the following parameters.


display_name: A friendly display name to use for this Policy Assignment. Changing this forces a new resource to be created. Here we are passing display name and description of the policy at single using collaps. Such that we can set policy Display name and Description at a single run time.

description:  A description to use for this Policy Assignment. Changing this forces a new resource to be created. `coalesce` function is used it will fetch based value on policy_name and policy_display_name variable.

policy_type: The policy type. Possible values are `BuiltIn`, `Custom` and `NotSpecified`.

mode: The policy mode that allows you to specify which resource types will be evaluated. Possible values are `All`, `Indexed`, `Microsoft.ContainerService.Data` etc.

management_group_name: The name which should be used for this Policy Assignment. `https://docs.microsoft.com/en-us/azure/governance/management-groups/overview`

policy_rule: The policy rule for the policy definition. This is a JSON string representing the rule that contains an if and a then block..

parameters: arameters for the policy definition. This field is a JSON string that allows you to parameterize your policy definition.


```terraform 
azurerm_subscription_policy_assignment
```
3. Azurerm_subscription_policy_assignment: It is a assignment of custom or existing policy definition or initiative on subscription level. it has following values supported.

name : The name which should be used for this Policy Assignment.

policy_definition_id:  This attribute is the ID of the Policy Definition. `coalesce` function is used in that first it will look out the value of existing policy, if existing policy get `null` value then it take the value of second parameters.

#### use case of coalese
```terraforn
> coalesce("a", "b")
a
> coalesce("", "b")
b
``` 

subscription_id:  ID of subscription to which policy assignment is set to be.

location: The Azure location where this policy assignment should exist.

parameters:   Set the value of definition parameters, it requires a JSON mapping.

Summary:

We have used this module with taking/calling necessory details with regards to enable policy for checking VM monitoring. Here in the description, we have added each module defination so that we can use them individually.
The standard module structure looks as follows:
-  main.tf, variable.tf, Files configuring a minimal module. Apart from main.tf, more complex modules may have additional resource configuration files from where we are calling barings module.

Custom Policy definitions are created using the azurerm_policy_definition resource and built-in policies are imported using the azurerm_policy_definition data resource. Both resources are included in the corresponding initiatives Terraform configuration file; unless they are shared across initiatives, in which case they are defined in the main.tf file.

It is important to note that policy data resource should be imported using its policy name (as opposed to they displayName), since the displayName is not unique and it may change, whereas the name is always unique and the same unless the policy is deleted. In the configuration, we kept the displayName commented out as it describes the policy definition being imported.

Custom Policy definitions are created using the azurerm_policy_definition resource and built-in policies are imported using the azurerm_policy_definition data resource. Both resources are included in the corresponding initiatives Terraform configuration file; unless they are shared across initiatives, in which case they are defined in the main.tf file.

Azure policies are defined as JSON, where we can define structurised json format for the policy. With the necessory perameter, we can define in the main.tf file and call barings template where necessory things required.


NOTE: Azure has limiatation for the each policy defination counts which we need to keep in mind with this ref link https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/azure-subscription-service-limits#azure-policy-limits provided by Microsoft.

* Reference 
`https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subscription_policy_assignment`
`https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/policy_set_definition`
`https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/policy_set_definition`



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

