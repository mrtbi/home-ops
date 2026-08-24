resource "proxmox_acme_certificate" "pve_proxy_cert" {
  node_name = var.proxmox_node_name
  account   = var.proxmox_acme_account

  domains = [
    {
      domain = var.proxmox_node_dns_name
      plugin = var.proxmox_acme_plugin
    }
  ]
}