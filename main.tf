data "azurerm_subscription" "current" {}

data "azurerm_policy_set_definition" "exist_policy" {
  count        = var.custom_policy_enabled ? 0 : 1
  display_name = var.exist_policy
}

resource "azurerm_policy_definition" "main_policy" {
  count                 = var.custom_policy_enabled ? 1 : 0
  name                  = var.policy_name
  display_name          = var.policy_display_name
  description           = coalesce(var.policy_description, var.policy_display_name)
  policy_type           = "Custom"
  mode                  = var.policy_mode
  management_group_name = var.policy_mgmt_group_name
  policy_rule           = var.policy_rule_content
  parameters            = var.policy_parameters_content
}

resource "azurerm_subscription_policy_assignment" "policy" {
  for_each             = var.policy_assignments
  name                 = each.value.name
  policy_definition_id = data.azurerm_policy_set_definition.exist_policy.0.id
  subscription_id      = data.azurerm_subscription.current.id
  location             = each.value.location
  parameters           = each.value.parameters
  identity {
    type = "SystemAssigned"
  }
}

