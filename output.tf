output "policy_definition_id" {
  value       = azurerm_policy_definition.main_policy.0.id
  description = "Azure policy ID"
}
