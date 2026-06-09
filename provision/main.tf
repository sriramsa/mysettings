# Recreate the "devbox" Azure dev VM from scratch (disaster recovery).
# All resources mirror the live box: B4ms / Ubuntu 22.04 gen2 / StandardSSD,
# static Standard public IP with a DNS label, system-assigned identity that can
# deallocate itself, and a nightly auto-shutdown with an email warning.
# OS setup is handled by cloud-init -> provision/bootstrap-devbox.sh.
#
# No identifying values live here; everything comes from terraform.tfvars.

terraform {
  required_version = ">= 1.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.vm_name}VNET"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.vm_name}Subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.vm_name}NSG"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # SSH. Defaults to "*" (anywhere) to match the live box; set
  # ssh_source_address to your IP/CIDR in tfvars to lock it down.
  security_rule {
    name                       = "allow-ssh"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.ssh_source_address
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "assoc" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Static + Standard so the address (and its DNS label) survives deallocation.
resource "azurerm_public_ip" "pip" {
  name                = "${var.vm_name}PublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = var.dns_label
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.vm_name}NIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                  = var.vm_name
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.nic.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(pathexpand(var.ssh_public_key_path))
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # Lets `devbox down` deallocate the VM from on the box (see role assignment).
  identity {
    type = "SystemAssigned"
  }

  # cloud-init: clone the repo and run the OS bootstrap on first boot.
  custom_data = base64encode(templatefile("${path.module}/cloud-init.yaml.tftpl", {
    admin    = var.admin_username
    repo_url = var.repo_url
  }))
}

# Scope "Virtual Machine Contributor" to the VM only (minimal blast radius).
resource "azurerm_role_assignment" "self_deallocate" {
  scope                = azurerm_linux_virtual_machine.vm.id
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = azurerm_linux_virtual_machine.vm.identity[0].principal_id
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "autoshutdown" {
  virtual_machine_id    = azurerm_linux_virtual_machine.vm.id
  location              = azurerm_resource_group.rg.location
  enabled               = true
  daily_recurrence_time = var.autoshutdown_time
  timezone              = var.autoshutdown_timezone

  notification_settings {
    enabled         = true
    time_in_minutes = var.autoshutdown_warn_minutes
    email           = var.autoshutdown_email
  }
}
