locals {
  pve_nodes = toset(["pve04"])
  talos_cp_nodes = toset(["ep-k8s-cp001", "ep-k8s-cp002", "ep-k8s-cp003"])
  talos_wk_nodes = toset(["ep-k8s-wk001", "ep-k8s-wk002", "ep-k8s-wk003", "ep-k8s-wk004"])
}

module "talos_control_plane_nodes" {
    for_each          = local.talos_cp_nodes

    source            = "../../modules/proxmox/vm"
    vm_name           = each.key
    proxmox_node_name = "pve04"
    agent_enabled     = true

    bios = "ovmf"
    efi_disk = {
      datastore_id = "gold"
    }

    cpu    = {
      cores = 4
    }

    memory = {
      dedicated = 8192
      floating  = 8192
    }

    disks = [
      {
        datastore_id = "gold"
        import_from  = "local:import/talos-v1.13.8-controlplane.qcow2"
        interface    = "virtio0"
        size         = 64
      }
    ]

    network_devices = [ 
      {
        bridge = "wirsol_ki"
      } 
    ]
}

module "talos_worker_nodes" {
    for_each          = local.talos_wk_nodes

    source            = "../../modules/proxmox/vm"
    vm_name           = each.key
    proxmox_node_name = "pve04"
    agent_enabled     = true

    bios = "ovmf"
    efi_disk = {
      datastore_id = "gold"
    }

    cpu    = {
      cores = 8
    }

    memory = {
      dedicated = 24576
      floating  = 24576
    }

    disks = [
      {
        datastore_id = "gold"
        import_from  = "local:import/talos-v1.13.8-worker.qcow2"
        interface    = "virtio0"
        size         = 128
      }
    ]

    network_devices = [ 
      {
        bridge = "wirsol_ki"
      } 
    ]
}