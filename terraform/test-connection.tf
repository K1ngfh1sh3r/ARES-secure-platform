data "proxmox_virtual_environment_nodes" "all" {}

output "proxmox_nodes" {
  description = "Nœuds détectés sur Proxmox"
  value       = data.proxmox_virtual_environment_nodes.all.names
}

output "proxmox_nodes_online" {
  description = "État des nœuds Proxmox"
  value       = data.proxmox_virtual_environment_nodes.all.online
}
