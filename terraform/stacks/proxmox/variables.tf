variable "infisical_client_id" {
  type = string
  sensitive = true
}

variable "infisical_client_secret" {
  type = string
  sensitive = true
}

variable "infisical_project_id" {
  type = string
  sensitive = true
}

variable "infisical_env_slug" {
  type = string
  default = "prod"
}

variable "proxmox_ve_username" {
  type = string
  sensitive = true
}

variable "proxmox_ve_password" {
  type = string
  sensitive = true
}

variable "tf_state_passphrase" {
  type = string
  sensitive = true
}

variable "aws_default_region" {
  type = string
  default = "eu-central"
}