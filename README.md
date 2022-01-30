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
