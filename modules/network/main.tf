###################Locals for Vnet & Its subnets##################
## Locals Block for Security Rules
locals {
  web_inbound_ports_map = {
    "100" : "80", # If the key starts with a number, you must use the colon syntax ":" instead of "="
    "110" : "443",
    "120" : "22"
  }
  app_inbound_ports_map = {
    "100" : "80", # If the key starts with a number, you must use the colon syntax ":" instead of "="
    "110" : "443",
    "120" : "8080",
    "130" : "22"
  }
  db_inbound_ports_map = {
    "100" : "3306", # If the key starts with a number, you must use the colon syntax ":" instead of "="
    "110" : "1433",
    "120" : "5432"
  }
  bastion_inbound_ports_map = {
    "100" : "22", # If the key starts with a number, you must use the colon syntax ":" instead of "="
    "110" : "3389"
  }   

}
###################################################################
# Create Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.resource_group_name}-network"
  address_space       = var.vnet_address_space
  location            = var.location
  resource_group_name = var.resource_group_name
  # tags = local.common_tags
}

###############################################Create WebTier Subnet##################################
# Resource-1: Create WebTier Subnet
resource "azurerm_subnet" "websubnet" {
  count                = length(var.web_subnet_address)
  name                 = "${var.resource_group_name}-subnet-${count.index + 1}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.web_subnet_address[count.index]]  
}

# Resource-2: Create Network Security Group (NSG)
resource "azurerm_network_security_group" "web_subnet_nsg" {
  name                = "websubnet-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
}

# Resource-3: Associate NSG and Subnet
resource "azurerm_subnet_network_security_group_association" "web_subnet_nsg_associate" {
  count                = length(azurerm_subnet.websubnet)
  depends_on = [ azurerm_network_security_rule.web_nsg_rule_inbound] # Every NSG Rule Association will disassociate NSG from Subnet and Associate it, so we associate it only after NSG is completely created - Azure Provider Bug https://github.com/terraform-providers/terraform-provider-azurerm/issues/354  
  subnet_id                 = azurerm_subnet.websubnet[count.index].id
  network_security_group_id = azurerm_network_security_group.web_subnet_nsg.id
}

# Resource-4: Create NSG Rules

## NSG Inbound Rule for WebTier Subnets
resource "azurerm_network_security_rule" "web_nsg_rule_inbound" {
  for_each = local.web_inbound_ports_map
  name                        = "Rule-Port-${each.value}"
  priority                    = each.key
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = each.value 
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.web_subnet_nsg.name
}

######################################################################################################
#################################################Web Tier#############################################
# Resource-1: Create AppTier Subnet
# resource "azurerm_subnet" "appsubnet" {
#   name                 = "${azurerm_virtual_network.vnet.name}-${var.app_subnet_name}"
#   resource_group_name  = var.resource_group_name
#   virtual_network_name = azurerm_virtual_network.vnet.name
#   address_prefixes     = var.app_subnet_address  
# }

# # Resource-2: Create Network Security Group (NSG)
# resource "azurerm_network_security_group" "app_subnet_nsg" {
#   name                = "${azurerm_subnet.appsubnet.name}-nsg"
#   location            = var.location
#   resource_group_name = var.resource_group_name
# }

# # Resource-3: Associate NSG and Subnet
# resource "azurerm_subnet_network_security_group_association" "app_subnet_nsg_associate" {
#   depends_on = [ azurerm_network_security_rule.app_nsg_rule_inbound]  
#   subnet_id                 = azurerm_subnet.appsubnet.id
#   network_security_group_id = azurerm_network_security_group.app_subnet_nsg.id
# }

# # Resource-4: Create NSG Rules

# ## NSG Inbound Rule for AppTier Subnets
# resource "azurerm_network_security_rule" "app_nsg_rule_inbound" {
#   for_each = local.app_inbound_ports_map
#   name                        = "Rule-Port-${each.value}"
#   priority                    = each.key
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "Tcp"
#   source_port_range           = "*"
#   destination_port_range      = each.value 
#   source_address_prefix       = "*"
#   destination_address_prefix  = "*"
#   resource_group_name         = var.resource_group_name
#   network_security_group_name = azurerm_network_security_group.app_subnet_nsg.name
# }
# ################################################################################################
# #################################################DB Tier#############################################
# # Resource-1: Create DBTier Subnet
# resource "azurerm_subnet" "dbsubnet" {
#   name                 = "${azurerm_virtual_network.vnet.name}-${var.db_subnet_name}"
#   resource_group_name  = var.resource_group_name
#   virtual_network_name = azurerm_virtual_network.vnet.name
#   address_prefixes     = var.db_subnet_address  
# }

# # Resource-2: Create Network Security Group (NSG)
# resource "azurerm_network_security_group" "db_subnet_nsg" {
#   name                = "${azurerm_subnet.dbsubnet.name}-nsg"
#   location            = var.location
#   resource_group_name = var.resource_group_name
# }

# # Resource-3: Associate NSG and Subnet
# resource "azurerm_subnet_network_security_group_association" "db_subnet_nsg_associate" {
#   depends_on = [ azurerm_network_security_rule.db_nsg_rule_inbound]  
#   subnet_id                 = azurerm_subnet.dbsubnet.id
#   network_security_group_id = azurerm_network_security_group.db_subnet_nsg.id
# }

# # Resource-4: Create NSG Rules
# ## NSG Inbound Rule for DBTier Subnets
# resource "azurerm_network_security_rule" "db_nsg_rule_inbound" {
#   for_each = local.db_inbound_ports_map
#   name                        = "Rule-Port-${each.value}"
#   priority                    = each.key
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "Tcp"
#   source_port_range           = "*"
#   destination_port_range      = each.value 
#   source_address_prefix       = "*"
#   destination_address_prefix  = "*"
#   resource_group_name         = var.resource_group_name
#   network_security_group_name = azurerm_network_security_group.db_subnet_nsg.name
# }

#######################################################################################################
#############################################Bastion Host######################################
# Resource-1: Create Bastion / Management Subnet
resource "azurerm_subnet" "bastionsubnet" {
  name                 = "${azurerm_virtual_network.vnet.name}-${var.bastion_subnet_name}"  
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.bastion_subnet_address
}

# Resource-2: Create Network Security Group (NSG)
resource "azurerm_network_security_group" "bastion_subnet_nsg" {
  name                = "${azurerm_subnet.bastionsubnet.name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
}

# Resource-3: Associate NSG and Subnet
resource "azurerm_subnet_network_security_group_association" "bastion_subnet_nsg_associate" {
  depends_on = [ azurerm_network_security_rule.bastion_nsg_rule_inbound]    
  subnet_id                 = azurerm_subnet.bastionsubnet.id
  network_security_group_id = azurerm_network_security_group.bastion_subnet_nsg.id
}

# Resource-4: Create NSG Rules

## NSG Inbound Rule for Bastion / Management Subnets
resource "azurerm_network_security_rule" "bastion_nsg_rule_inbound" {
  for_each = local.bastion_inbound_ports_map
  name                        = "Rule-Port-${each.value}"
  priority                    = each.key
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = each.value 
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.bastion_subnet_nsg.name
}
########################################################################################