# Network Interface Outputs
## Network Interface ID
output "web_linuxvm_network_interface_id" {
  description = "Web Linux VM web_linuxvm_nic Interface ID"
  value = azurerm_network_interface.web_linuxvm_nic.id
}
## Network Interface Private IP Addresses
output "web_linuxvm_network_interface_private_ip_addresses" {
  description = "Web Linux VM Private IP Addresses"
  value = azurerm_network_interface.web_linuxvm_nic.private_ip_addresses
}

## Network Interface Private IP Configurations
# output "web_linuxvm_network_interface_private_ip_configurations" {
#   description = "Web Linux VM Private IP Addresses"
#   value = [azurerm_network_interface.web_linuxvm_nic.ip_configuration[*].name]
# }
