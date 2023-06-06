#Root module calling for Rajesh Project
locals {
  resource_group_name = var.resource_group_name
  location = var.location
}
#NetWork Module Calling
module "network" {
  source     = "./modules/network"
  resource_group_name   = local.resource_group_name
  location   = local.location
  vnet_name = var.vnet_name
  vnet_address_space = var.vnet_address_space
  web_subnet_name = var.web_subnet_name
  web_subnet_address = var.web_subnet_address
  app_subnet_name = var.app_subnet_name
  app_subnet_address = var.app_subnet_address
  db_subnet_name = var.db_subnet_name
  db_subnet_address = var.db_subnet_address
  bastion_subnet_name = var.bastion_subnet_name
  bastion_subnet_address = var.bastion_subnet_address
}

#VM Module Calling
module "virtual_machine" {
  source     = "./modules/vm"
  resource_group_name   = local.resource_group_name
  location   = local.location
  web_subnet_id  = module.network.web_subnet_id
}

#Bastion Module Calling
module "bastion" {
  source     = "./modules/bastion"
  resource_group_name   = local.resource_group_name
  location   = local.location
  bastion_subnet_id  = module.network.bastion_subnet_id
}

#Load Balncer Module Calling
module "elb" {
  source     = "./modules/elb"
  resource_group_name   = local.resource_group_name
  location   = local.location
  web_subnet_id  = module.network.web_subnet_id
  vm_net_info = module.virtual_machine.web_linuxvm_network_interface_private_ip_addresses
  vm_net_nicid = module.virtual_machine.web_linuxvm_network_interface_id
  virtual_network_id = module.network.virtual_network_id
}

## Network Interface Private IP Configurations
output "web_linuxvm_network_interface_private_ip_configurations" {
  description = "Web Linux VM Private IP Addresses"
  value = module.virtual_machine.web_linuxvm_network_interface_private_ip_addresses
}

