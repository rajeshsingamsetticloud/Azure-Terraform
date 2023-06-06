############################From Root main.tf#######################################################
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be provisioned"
  type        = string
}
####################################################################################################
# Web Subnet Address Space
variable "web_subnet_id" {
  description = "Getting Web Subnet From virutal network module"
  type = list(string)
}