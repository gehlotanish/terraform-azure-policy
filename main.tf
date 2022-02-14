data "azurerm_subscription" "current" {}

data "azurerm_policy_set_definition" "exist_policy" {
  count        = alltrue([var.initiative_enabled, var.custom_policy_disabled]) ? 1 : 0
  display_name = var.exist_policy
}

data "azurerm_policy_definition" "exist_policy" {
  count        = alltrue([var.initiative_enabled, var.custom_policy_disabled]) ? 0 : 1
  display_name = var.exist_policy
}

resource "azurerm_policy_definition" "main_policy" {
  count = alltrue([var.initiative_enabled, var.custom_policy_disabled]) ? 0 : 1

  name         = var.policy_name
  display_name = var.policy_display_name
  description  = coalesce(var.policy_description, var.policy_display_name)
  policy_type  = "Custom"
  mode         = var.policy_mode
  policy_rule  = var.policy_rule_content
  parameters   = var.policy_parameters_content
}

resource "azurerm_subscription_policy_assignment" "policy" {
  for_each             = var.policy_assignments
  name                 = each.value.name
  policy_definition_id = coalesce(var.initiative_enabled ? one(data.azurerm_policy_set_definition.exist_policy.*.id) : one(data.azurerm_policy_definition.exist_policy.*.id), one(azurerm_policy_definition.main_policy.*.id))
  subscription_id      = data.azurerm_subscription.current.id
  location             = each.value.location
  parameters           = each.value.parameters
  identity {
    type = "SystemAssigned"
  }
}

