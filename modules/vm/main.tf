# Locals Block for custom data
locals {
webvm_custom_data = <<CUSTOM_DATA
#!/bin/sh
#sudo yum update -y
sudo yum install -y httpd
sudo systemctl enable httpd
sudo systemctl start httpd  
sudo systemctl stop firewalld
sudo systemctl disable firewalld
sudo chmod -R 777 /var/www/html 
sudo echo "Welcome to stacksimplify - WebVM App1 - VM Hostname: $(hostname)" > /var/www/html/index.html
sudo mkdir /var/www/html/app1
sudo echo "Welcome to stacksimplify - WebVM App1 - VM Hostname: $(hostname)" > /var/www/html/app1/hostname.html
sudo echo "Welcome to stacksimplify - WebVM App1 - App Status Page" > /var/www/html/app1/status.html
sudo echo '<!DOCTYPE html> <html> <body style="background-color:rgb(250, 210, 210);"> <h1>Welcome to Stack Simplify - WebVM APP-1 </h1> <p>Terraform Demo</p> <p>Application Version: V1</p> </body></html>' | sudo tee /var/www/html/app1/index.html
sudo curl -H "Metadata:true" --noproxy "*" "http://169.254.169.254/metadata/instance?api-version=2020-09-01" -o /var/www/html/app1/metadata.html
CUSTOM_DATA
}

# Resource-1: Create Public IP Address
resource "azurerm_public_ip" "web_linuxvm_publicip" {
  name = "${var.resource_group_name}-web-linux-pubip"
  resource_group_name = var.resource_group_name
  location = var.location
  allocation_method = "Static"
  sku = "Standard"
#   domain_name_label = "app1-vm-${random_string.myrandom.id}"
}

# Resource-2: Create Network Interface
resource "azurerm_network_interface" "web_linuxvm_nic" {
  name = "${var.resource_group_name}-web-linuxvm"
  location = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name = "web-linuxvm-ip-1"
    subnet_id = var.web_subnet_id[0]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.web_linuxvm_publicip.id
  }
}

# Resource-3: Azure Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "web_linuxvm" {
  name = "Rajesh-web-linuxvm"
  #computer_name = "web-linux-vm" # Hostname of the VM (Optional)
  resource_group_name = var.resource_group_name
  location = var.location
  size = "Standard_B1s"
  admin_username = "azureuser"
  admin_password = "raj@8932domain123"
  disable_password_authentication = false
  network_interface_ids = [ azurerm_network_interface.web_linuxvm_nic.id ]
  # admin_ssh_key {
  #   username   = "azureuser"
  #   public_key = file("~/.ssh/id_rsa.pub")
  # }
  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  } 
  source_image_reference {
    publisher = "RedHat"
    offer = "RHEL"
    sku = "7.7"
    version = "latest"
  }  
  #custom_data = filebase64("${path.module}/app-scripts/redhat-webvm-script.sh")
  custom_data = base64encode(local.webvm_custom_data)
}