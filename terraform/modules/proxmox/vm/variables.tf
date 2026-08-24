variable "proxmox_node_name" {
  type = string
}

variable "vm_name" {
  type = string
}

variable "vm_id" {
  type    = number
  default = null
}

variable "description" {
  type    = string
  default = "Managed by Terraform"
}

variable "tags" {
  type    = list(string)
  default = []
}

variable "pool_id" {
  type    = string
  default = null
}

variable "template" {
  type    = bool
  default = false
}

variable "started" {
  type    = bool
  default = true
}

variable "on_boot" {
  type    = bool
  default = true
}

variable "protection" {
  type    = bool
  default = false
}

variable "stop_on_destroy" {
  type    = bool
  default = true
}

variable "agent_enabled" {
  type    = bool
  default = false
}

variable "startup" {
  type = object({
    order      = optional(string)
    up_delay   = optional(string)
    down_delay = optional(string)
  })
  default = null
}

variable "cpu" {
  type = object({
    cores   = optional(number, 2)
    sockets = optional(number, 1)
    type    = optional(string, "x86-64-v2-AES")
  })
  default = {}
}

variable "memory" {
  type = object({
    dedicated = optional(number, 2048)
    floating  = optional(number, 0)
  })
  default = {}
}

variable "cdrom" {
  type = object({
    file_id   = optional(string, "none")
    interface = optional(string, "ide3")
  })
  default = {}
}

variable "disks" {
  description = "One entry per disk block on the VM."
  type = list(object({
    datastore_id = string
    interface    = string
    size         = optional(number, 8)
    file_format  = optional(string, "raw")
    import_from  = optional(string)
    discard      = optional(string, "on")
    ssd          = optional(bool, false)
  }))
  default = []
}

variable "network_devices" {
  description = "One entry per network_device block on the VM."
  type = list(object({
    bridge  = optional(string, "vmbr0")
    model   = optional(string, "virtio")
    vlan_id = optional(number)
  }))
  default = [{}]
}

variable "operating_system_type" {
  type    = string
  default = "l26"
}

variable "clone" {
  type = object({
    vm_id        = number
    node_name    = optional(string)
    datastore_id = optional(string)
    full         = optional(bool, true)
  })
  default = null
}

variable "initialization" {
  type = object({
    datastore_id      = optional(string)
    user_data_file_id = optional(string)
    meta_data_file_id = optional(string)
    dns_servers       = optional(list(string))
    ip_config = optional(object({
      ipv4_address = optional(string, "dhcp")
      ipv4_gateway = optional(string)
    }), {})
    user_account = optional(object({
      username = string
      keys     = optional(list(string))
      password = optional(string)
    }))
  })
  default = null
}

variable "tpm_enabled" {
  type    = bool
  default = false
}

variable "bios" {
  description = "BIOS implementation: \"seabios\" or \"ovmf\" (UEFI)."
  type        = string
  default     = "seabios"

  validation {
    condition     = contains(["seabios", "ovmf"], var.bios)
    error_message = "bios must be either \"seabios\" or \"ovmf\"."
  }
}

variable "efi_disk" {
  description = "EFI disk configuration, required when bios = \"ovmf\"."
  type = object({
    datastore_id      = string
    file_format       = optional(string, "raw")
    type              = optional(string, "4m")
    pre_enrolled_keys = optional(bool, false)
  })
  default = null
}

variable "serial_device_enabled" {
  type    = bool
  default = false
}
