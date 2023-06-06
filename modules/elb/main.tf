# Resource-1: Create Public IP Address for Azure Load Balancer
resource "azurerm_public_ip" "web_lbpublicip" {
  name = "${var.resource_group_name}-lbpublicip"
  resource_group_name = var.resource_group_name
  location = var.location
  allocation_method = "Static"
  sku = "Standard"
}


# Resource-2: Create Azure Standard Load Balancer
resource "azurerm_lb" "web_lb" {
  name = "${var.resource_group_name}-web-lb"
  resource_group_name = var.resource_group_name
  location = var.location
  sku = "Standard"

  frontend_ip_configuration {
    name = "web-lb-publicip-1"
    # subnet_id            = var.web_subnet_id[1]
    public_ip_address_id = azurerm_public_ip.web_lbpublicip.id
  }
  
  depends_on = [ 
    azurerm_public_ip.web_lbpublicip
   ]
} 

resource "azurerm_lb_backend_address_pool" "PoolA" {
  loadbalancer_id = azurerm_lb.web_lb.id
  name            = "BackEndAddressPool"
  depends_on = [ 
    azurerm_lb.web_lb
   ]
}

resource "azurerm_lb_backend_address_pool_address" "example-2" {
  count = length(var.vm_net_info)
  name                                = "addressvmIP${count.index}"
  backend_address_pool_id             = azurerm_lb_backend_address_pool.PoolA.id
  virtual_network_id = var.virtual_network_id
  ip_address = var.vm_net_info[count.index]
}

resource "azurerm_lb_probe" "example" {
  name                = "slb-probe"
  loadbalancer_id     = azurerm_lb.web_lb.id
  protocol            = "Http"
  port                = 80
  number_of_probes    = 2
  request_path        = "/"
}

resource "azurerm_lb_rule" "example" {
  name                     = "slb-rule"
  loadbalancer_id          = azurerm_lb.web_lb.id
  protocol                 = "Tcp"
  frontend_port            = 80
  backend_port             = 80
  frontend_ip_configuration_name = "web-lb-publicip-1"
  backend_address_pool_ids  = [azurerm_lb_backend_address_pool.PoolA.id]
  probe_id                 = azurerm_lb_probe.example.id 
}
