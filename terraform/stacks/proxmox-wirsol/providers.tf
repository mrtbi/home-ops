terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.111.1"
    }
  }
}

provider "proxmox" {
  endpoint  = "https://10.13.255.14:8006"
  insecure = true
  username  = "root@pam"
  password  = "096B9@v9f*uwN7$0z8%6"
}