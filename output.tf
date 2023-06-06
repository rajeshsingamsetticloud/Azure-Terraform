
## Subnet ID 
output "web_subnet_id" {
  description = "WebTier Subnet ID"
  value = module.network.web_subnet_id
}

# output "tls_private_key" {
#   description = "WebTier Subnet ID"
#   value = module.virtual_machine.tls_private_key
#   sensitive = true
# }


