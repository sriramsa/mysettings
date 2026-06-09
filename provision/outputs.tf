output "fqdn" {
  description = "Stable DNS name — use this as DEVBOX_SSH."
  value       = azurerm_public_ip.pip.fqdn
}

output "public_ip" {
  value = azurerm_public_ip.pip.ip_address
}

output "ssh" {
  description = "SSH straight in once cloud-init finishes."
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.pip.fqdn}"
}

output "identity_principal_id" {
  description = "The VM's managed identity (already granted VM Contributor on itself)."
  value       = azurerm_linux_virtual_machine.vm.identity[0].principal_id
}
