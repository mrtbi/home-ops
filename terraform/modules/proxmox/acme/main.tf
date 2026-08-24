resource "proxmox_acme_account" "acme_account" {
  name      = "default"
  contact   = var.acme_contact_email
  directory = "https://acme-v02.api.letsencrypt.org/directory"
  tos       = "https://letsencrypt.org/documents/LE-SA-v1.3-September-21-2022.pdf"
}

resource "proxmox_acme_dns_plugin" "acme_plugin" {
  plugin = "hetznercloud"
  api    = "hetznercloud"
  data = {
    HETZNER_TOKEN = var.acme_plugin_hetzner_token
  }
}