terraform {
  required_version = ">= 1.4.0"

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

locals {
  node_names = keys(var.nodes)

  # All ordered source-destination VNet peering pairs.
  peering_pairs = flatten([
    for source_name, source_node in var.nodes : [
      for target_name, target_node in var.nodes : {
        source_name = source_name
        target_name = target_name
      }
      if source_name != target_name
    ]
  ])

  peering_map = {
    for pair in local.peering_pairs :
    "${pair.source_name}-to-${pair.target_name}" => pair
  }
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.nodes["cloudeco-master"].location

  tags = var.tags
}

resource "azurerm_virtual_network" "node" {
  for_each = var.nodes

  name                = "${each.key}-vnet"
  address_space       = [each.value.address_space]
  location            = each.value.location
  resource_group_name = azurerm_resource_group.main.name

  tags = merge(var.tags, {
    node = each.key
    role = each.value.role
  })
}

resource "azurerm_subnet" "node" {
  for_each = var.nodes

  name                 = "${each.key}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.node[each.key].name
  address_prefixes     = [each.value.subnet_prefix]
}

resource "azurerm_network_security_group" "node" {
  for_each = var.nodes

  name                = "${each.key}-nsg"
  location            = each.value.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.admin_source_cidr
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-kubernetes-api"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6443"
    source_address_prefix      = var.admin_source_cidr
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-nodeport-range"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["30000-32767"]
    source_address_prefix      = var.admin_source_cidr
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-vnet-internal"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefixes    = [for _, node in var.nodes : node.address_space]
    destination_address_prefix = "*"
  }

  tags = merge(var.tags, {
    node = each.key
    role = each.value.role
  })
}

resource "azurerm_subnet_network_security_group_association" "node" {
  for_each = var.nodes

  subnet_id                 = azurerm_subnet.node[each.key].id
  network_security_group_id = azurerm_network_security_group.node[each.key].id
}

resource "azurerm_virtual_network_peering" "node" {
  for_each = local.peering_map

  name                      = each.key
  resource_group_name       = azurerm_resource_group.main.name
  virtual_network_name      = azurerm_virtual_network.node[each.value.source_name].name
  remote_virtual_network_id = azurerm_virtual_network.node[each.value.target_name].id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_public_ip" "node" {
  for_each = var.nodes

  name                = "${each.key}-pip"
  location            = each.value.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = merge(var.tags, {
    node = each.key
    role = each.value.role
  })
}

resource "azurerm_network_interface" "node" {
  for_each = var.nodes

  name                = "${each.key}-nic"
  location            = each.value.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.node[each.key].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.node[each.key].id
  }

  tags = merge(var.tags, {
    node = each.key
    role = each.value.role
  })
}

resource "azurerm_linux_virtual_machine" "node" {
  for_each = var.nodes

  name                = each.key
  resource_group_name = azurerm_resource_group.main.name
  location            = each.value.location
  size                = each.value.vm_size
  admin_username      = var.admin_username

  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.node[each.key].id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    name                 = "${each.key}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  tags = merge(var.tags, {
    node = each.key
    role = each.value.role
  })
}