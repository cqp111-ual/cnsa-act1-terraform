# CNSA - Activity 01 [https://ualcnsa.github.io/cicd/despliegue-continuo/v.2025/infraestructura/index.html]

######################
## Global resources ##
######################

# Resource group
resource "azurerm_resource_group" "tf-resource-group" {
  name     = var.azure-resource-group
  location = var.azure-location
}

# Network and subnetwork
resource "azurerm_virtual_network" "tf-net" {
  name                = var.azure-net-name
  location            = azurerm_resource_group.tf-resource-group.location
  resource_group_name = azurerm_resource_group.tf-resource-group.name
  address_space       = var.azure-address-space
  dns_servers         = var.azure-dns-servers
}

resource "azurerm_subnet" "tf-subnet" {
  name                 = var.azure-subnet-name
  resource_group_name  = azurerm_resource_group.tf-resource-group.name
  virtual_network_name = azurerm_virtual_network.tf-net.name
  address_prefixes     = var.azure-subnet-prefixes
}

# Security Group (common for both machines)
resource "azurerm_network_security_group" "tf-nsg" {
  name                = "tf-nsg"
  location            = azurerm_resource_group.tf-resource-group.location
  resource_group_name = azurerm_resource_group.tf-resource-group.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Jenkins-Docker"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Spring-Boot-Apps"
    priority                   = 1005
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080-8081"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Nodejs-Apps"
    priority                   = 1006
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3000-3001"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

##################
## Jenkins Node ##
##################

# Public IP
resource "azurerm_public_ip" "tf-jenkins-ip" {
  name                = "tf-jenkins-ip"
  location            = azurerm_resource_group.tf-resource-group.location
  resource_group_name = azurerm_resource_group.tf-resource-group.name
  domain_name_label   = var.jenkins-vm-name
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}

# Network interface
resource "azurerm_network_interface" "tf-jenkins-nic" {
  name                = "tf-jenkins-nic"
  location            = azurerm_resource_group.tf-resource-group.location
  resource_group_name = azurerm_resource_group.tf-resource-group.name

  ip_configuration {
    name      = "internal"
    subnet_id = azurerm_subnet.tf-subnet.id
    # # Here we can apply either Static or Dynamic
    # private_ip_address_allocation = "Dynamic"
    private_ip_address_allocation = "Static"
    private_ip_address            = var.jenkins-privateip-address
    public_ip_address_id          = azurerm_public_ip.tf-jenkins-ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "tf-jenkins-nic-nsg" {
  network_interface_id      = azurerm_network_interface.tf-jenkins-nic.id
  network_security_group_id = azurerm_network_security_group.tf-nsg.id
}

# VM instance
resource "azurerm_linux_virtual_machine" "tf-jenkins" {
  name                = var.jenkins-vm-name
  resource_group_name = azurerm_resource_group.tf-resource-group.name
  location            = azurerm_resource_group.tf-resource-group.location
  size                = var.azure-vm-size
  admin_username      = var.azure-admin-username
  network_interface_ids = [
    azurerm_network_interface.tf-jenkins-nic.id,
  ]

  admin_ssh_key {
    username   = var.azure-admin-username
    public_key = file("${path.module}/keys/cnsa-cqp111.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.azure-storage-account-type
  }

  source_image_reference {
    publisher = var.azure-os-publisher
    offer     = var.azure-os-offer
    sku       = var.azure-os-sku
    version   = var.azure-os-version
  }

  # custom_data = data.cloudinit_config.jenkins_cloud_init.rendered
}

output "tf-jenkins-fqdn" {
  value      = azurerm_public_ip.tf-jenkins-ip.fqdn
  depends_on = [azurerm_linux_virtual_machine.tf-jenkins]
}

output "tf-jenkins-public-ip" {
  value      = azurerm_public_ip.tf-jenkins-ip.ip_address
  depends_on = [azurerm_linux_virtual_machine.tf-jenkins]
}


#####################
## Deployment Node ##
#####################

# Public IP
resource "azurerm_public_ip" "tf-deploy-ip" {
  name                = "tf-deploy-ip"
  location            = azurerm_resource_group.tf-resource-group.location
  resource_group_name = azurerm_resource_group.tf-resource-group.name
  domain_name_label   = var.deploy-vm-name
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}

# Network interface
resource "azurerm_network_interface" "tf-deploy-nic" {
  name                = "tf-deploy-nic"
  location            = azurerm_resource_group.tf-resource-group.location
  resource_group_name = azurerm_resource_group.tf-resource-group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.tf-subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.deploy-privateip-address
    public_ip_address_id          = azurerm_public_ip.tf-deploy-ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "tf-deploy-nic-nsg" {
  network_interface_id      = azurerm_network_interface.tf-deploy-nic.id
  network_security_group_id = azurerm_network_security_group.tf-nsg.id
}

# VM instance
resource "azurerm_linux_virtual_machine" "tf-deploy" {
  name                = var.deploy-vm-name
  resource_group_name = azurerm_resource_group.tf-resource-group.name
  location            = azurerm_resource_group.tf-resource-group.location
  size                = var.azure-vm-size
  admin_username      = var.azure-admin-username
  network_interface_ids = [
    azurerm_network_interface.tf-deploy-nic.id,
  ]

  admin_ssh_key {
    username   = var.azure-admin-username
    public_key = file("${path.module}/keys/cnsa-cqp111.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.azure-storage-account-type
  }

  source_image_reference {
    publisher = var.azure-os-publisher
    offer     = var.azure-os-offer
    sku       = var.azure-os-sku
    version   = var.azure-os-version
  }

  # custom_data = data.cloudinit_config.jenkins_cloud_init.rendered
}

output "tf-deploy-fqdn" {
  value      = azurerm_public_ip.tf-deploy-ip.fqdn
  depends_on = [azurerm_linux_virtual_machine.tf-deploy]
}

output "tf-deploy-public-ip" {
  value      = azurerm_public_ip.tf-deploy-ip.ip_address
  depends_on = [azurerm_linux_virtual_machine.tf-deploy]
}