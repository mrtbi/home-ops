resource "proxmox_virtual_environment_vm" "vm" {
  name        = var.vm_name
  description = var.description
  tags        = var.tags

  node_name = var.proxmox_node_name
  vm_id     = var.vm_id
  pool_id   = var.pool_id

  template        = var.template
  started         = var.started
  on_boot         = var.on_boot
  protection      = var.protection
  stop_on_destroy = var.stop_on_destroy

  agent {
    enabled = var.agent_enabled
  }

  dynamic "startup" {
    for_each = var.startup != null ? [var.startup] : []
    content {
      order      = startup.value.order
      up_delay   = startup.value.up_delay
      down_delay = startup.value.down_delay
    }
  }

  dynamic "clone" {
    for_each = var.clone != null ? [var.clone] : []
    content {
      vm_id        = clone.value.vm_id
      node_name    = clone.value.node_name
      datastore_id = clone.value.datastore_id
      full         = clone.value.full
    }
  }

  cpu {
    cores   = var.cpu.cores
    sockets = var.cpu.sockets
    type    = var.cpu.type
  }

  memory {
    dedicated = var.memory.dedicated
    floating  = var.memory.floating
  }

  cdrom {
    file_id   = var.cdrom.file_id
    interface = var.cdrom.interface
  }

  dynamic "disk" {
    for_each = var.disks
    content {
      datastore_id = disk.value.datastore_id
      interface    = disk.value.interface
      size         = disk.value.size
      file_format  = disk.value.file_format
      import_from  = disk.value.import_from
      discard      = disk.value.discard
      ssd          = disk.value.ssd
    }
  }

  dynamic "network_device" {
    for_each = var.network_devices
    content {
      bridge  = network_device.value.bridge
      model   = network_device.value.model
      vlan_id = network_device.value.vlan_id
    }
  }

  dynamic "initialization" {
    for_each = var.initialization != null ? [var.initialization] : []
    content {
      datastore_id      = initialization.value.datastore_id
      user_data_file_id = initialization.value.user_data_file_id
      meta_data_file_id = initialization.value.meta_data_file_id
      dns {
        servers = initialization.value.dns_servers
      }

      ip_config {
        ipv4 {
          address = initialization.value.ip_config.ipv4_address
          gateway = initialization.value.ip_config.ipv4_gateway
        }
      }

      dynamic "user_account" {
        for_each = initialization.value.user_account != null ? [initialization.value.user_account] : []
        content {
          username = user_account.value.username
          keys     = user_account.value.keys
          password = user_account.value.password
        }
      }
    }
  }

  operating_system {
    type = var.operating_system_type
  }

  bios = var.bios

  dynamic "efi_disk" {
    for_each = var.efi_disk != null ? [var.efi_disk] : []
    content {
      datastore_id      = efi_disk.value.datastore_id
      file_format       = efi_disk.value.file_format
      type              = efi_disk.value.type
      pre_enrolled_keys = efi_disk.value.pre_enrolled_keys
    }
  }

  dynamic "tpm_state" {
    for_each = var.tpm_enabled ? [1] : []
    content {
      version = "v2.0"
    }
  }

  dynamic "serial_device" {
    for_each = var.serial_device_enabled ? [1] : []
    content {}
  }
}
