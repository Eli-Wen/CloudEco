output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "node_summary" {
  value = {
    for name, node in var.nodes :
    name => {
      role       = node.role
      location   = node.location
      vm_size    = node.vm_size
      public_ip  = azurerm_public_ip.node[name].ip_address
      private_ip = azurerm_network_interface.node[name].private_ip_address
    }
  }
}

output "ssh_commands" {
  value = {
    for name, node in var.nodes :
    name => "ssh -i ../keys/cloudeco_a1_key ${var.admin_username}@${azurerm_public_ip.node[name].ip_address}"
  }
}

output "acr_name" {
  value = azurerm_container_registry.main.name
}

output "acr_login_server" {
  value = azurerm_container_registry.main.login_server
}