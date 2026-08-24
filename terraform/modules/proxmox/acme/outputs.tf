output "acme_plugin" {
  value = proxmox_acme_dns_plugin.acme_plugin.plugin
}

output "acme_account" {
  value = proxmox_acme_account.acme_account.name
}