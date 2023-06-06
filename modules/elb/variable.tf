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

variable "vm_net_info" {
  description = "Getting Web vm_net_info From virutal vm module"
  type        = list(string)
}

variable "virtual_network_id" {
  description = "Getting Web vm_net_info From virutal vm module"
  type        = string
}

variable "vm_net_nicid" {
  description = "Azure VM Nic id"
  type        = string
}
variable "backend_pool_name" {
  description = "Azure VM Nic id"
  type        = string
  default = "my-lb-backend-pool"
}

variable "health_probe_name" {
  description = "Azure VM Nic id"
  type        = string
  default = "tcp-probe"
}



