terraform {
  backend "s3" {
   
    bucket = "hometfstate"
    key    = "stacks/proxmox/terraform.tfstate"
    endpoints = {
      s3 = "fsn1.your-objectstorage.com"
    }

    skip_requesting_account_id = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    use_path_style            = true
  }
  required_providers {
    infisical = {
      source  = "infisical/infisical"
      version = "0.19.24"  
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.111.1"
    }
  }
  encryption {
    key_provider "pbkdf2" "tf_state_key_provider" {
      passphrase = var.tf_state_passphrase
    }
    method "aes_gcm" "aes_gcm_state_enc" {
      keys = key_provider.pbkdf2.tf_state_key_provider
    }
    state {
      method = method.aes_gcm.aes_gcm_state_enc
    }
  }
}

provider "infisical" {
  host = "https://eu.infisical.com"

  auth = {
    universal = {
      client_id     = var.infisical_client_id
      client_secret = var.infisical_client_secret
    }
  }
}

provider "proxmox" {
  endpoint  = "https://pve.mrtb.io:8006/"
  insecure = true
  username  = var.proxmox_ve_username
  password  = var.proxmox_ve_password
}