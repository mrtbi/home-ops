locals {
  pve_nodes = toset(["pve"])
  talos_cp_nodes = toset(["cp001", "cp002", "cp003"])
}

data "infisical_secrets" "proxmox_secrets" {
  env_slug     = "prod"
  workspace_id = var.infisical_project_id
  folder_path  = "/proxmox"
}

module "proxmox_acme_config" {
    source                    = "../../modules/proxmox/acme"
    acme_contact_email        = "ops@mrtb.io"
    acme_plugin_hetzner_token = nonsensitive(data.infisical_secrets.proxmox_secrets.secrets["HETZNER_TOKEN"].value)
}

module "proxmox_acme_cert" {
    for_each              = local.pve_nodes

    source                = "../../modules/proxmox/acme-cert"
    proxmox_node_name     = each.key
    proxmox_node_dns_name = "${each.key}.mrtb.io"
    proxmox_acme_account  = module.proxmox_acme_config.acme_account
    proxmox_acme_plugin   = module.proxmox_acme_config.acme_plugin
    depends_on = [ module.proxmox_acme_config ]
}

module "talos_control_plane_nodes" {
    for_each          = local.talos_cp_nodes

    source            = "../../modules/proxmox/vm"
    vm_name           = each.key
    proxmox_node_name = "pve"
    agent_enabled     = true

    cpu    = {
      cores = 2
    }

    memory = {
      dedicated = 4096
      floating  = 4096
    }

    disks = [
      {
        datastore_id = "local-lvm"
        interface    = "scsi0"
        size         = 32
      }
    ]

    cdrom = {
      file_id = "local:iso/talos-v1.13.8-metal.iso"
    }

    network_devices = [ 
      {
        bridge = "vmbr0"
      } 
    ]
}

data "local_file" "ssh_public_key" {
  filename = pathexpand("~/.ssh/id_ed25519.pub")
}

resource "proxmox_virtual_environment_file" "user_data_cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "pve"

  source_raw {
    data = <<-EOF
    #cloud-config
    timezone: Europe/Berlin
    users:
      - default
      - name: ${nonsensitive(data.infisical_secrets.proxmox_secrets.secrets["LINUX_USERNAME"].value)}
        groups:
          - sudo
        shell: /bin/bash
        ssh_authorized_keys:
          - ${trimspace(data.local_file.ssh_public_key.content)}
        sudo: ALL=(ALL) NOPASSWD:ALL
    package_update: true
    packages:
      - qemu-guest-agent
      - net-tools
      - curl
    runcmd:
      - systemctl enable qemu-guest-agent
      - systemctl start qemu-guest-agent
      - echo "done" > /tmp/cloud-config.done
    EOF

    file_name = "user-data-cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_file" "meta_data_iota" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "pve"

  source_raw {
    data = <<-EOF
    #cloud-config
    local-hostname: iota
    EOF

    file_name = "meta-data-iota.yaml"
  }
}

module "server_iota" {
    source            = "../../modules/proxmox/vm"
    vm_name           = "iota"
    proxmox_node_name = "pve"
    agent_enabled     = true

    cpu    = {
      cores = 2
    }

    memory = {
      dedicated = 2048
      floating  = 2048
    }

    initialization = {
      user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
      meta_data_file_id = proxmox_virtual_environment_file.meta_data_iota.id
    }

    disks = [
      {
        datastore_id = "local-lvm"
        import_from  = "local:import/resolute-server-cloudimg-amd64.qcow2"
        interface    = "virtio0"
        size         = 32
      },
      {
        datastore_id = "local-lvm"
        interface    = "scsi1"
        size         = 64
      }
    ]

    network_devices = [ 
      {
        bridge = "vmbr0"
      } 
    ]
}