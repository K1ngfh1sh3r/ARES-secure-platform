resource "proxmox_virtual_environment_vm" "ares_tf_test" {
  name      = "ares-tf-test"
  vm_id     = 140
  node_name = "pve"

  description = "VM de test provisionnee par Terraform"

  clone {
    vm_id = 9000
  }

  agent {
    enabled = true
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 2048
  }

  initialization {
    datastore_id = "local-lvm"

    dns {
      servers = ["10.20.20.1"]
    }

    user_account {
      username = "aresadmin"
      keys = [
        trimspace(file(pathexpand("~/.ssh/id_ed25519.pub")))
      ]
    }

    ip_config {
      ipv4 {
        address = "10.20.20.20/24"
        gateway = "10.20.20.1"
      }
    }
  }

  network_device {
    bridge  = "vmbr1"
    model   = "virtio"
    vlan_id = 20
  }
}
