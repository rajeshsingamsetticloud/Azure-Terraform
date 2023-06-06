resource_group_name = "rg_eastus_49757_1_168602749418"
location = "eastus"
#Vnet variables
vnet_name = "vnet"
vnet_address_space = ["10.1.0.0/16"]
web_subnet_name = "websubnet"
web_subnet_address = ["10.1.1.0/24","10.1.10.0/24"]

app_subnet_name = "appsubnet"
app_subnet_address = ["10.1.11.0/24"]

db_subnet_name = "dbsubnet"
db_subnet_address = ["10.1.21.0/24"]

bastion_subnet_name = "bastionsubnet"
bastion_subnet_address = ["10.1.100.0/24"]

# bastion_service_subnet_name = "AzureBastionSubnet"
# bastion_service_address_prefixes = ["10.1.101.0/27"]