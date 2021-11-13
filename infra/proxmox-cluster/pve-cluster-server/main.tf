terraform {
  required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
    }
  }
}


# volumes to attach to the proxmox servers (10GB)
resource "libvirt_volume" "proxmox_boot" {
  name          = "proxmox_boot-${var.cluster_server_name}"
  size          = "${var.boot_disk_size}"
  pool          = "${var.pool_cluster_name}"
}

# volumes to attach to the proxmox servers (100GB)
resource "libvirt_volume" "proxmox_data" {
  name          = "proxmox_data-${var.cluster_server_name}"
  size          = "${var.data_disk_size}"
  pool          = "${var.pool_cluster_name}"
}


resource "libvirt_domain" "pve-cluster-server" {
  name        = "${var.cluster_server_name}"
  description = "Always on Support Server"
  memory      = "2000"
  vcpu        = 1
  running     = "false"


  network_interface {
    # network_name = "default"
    hostname   = "test-vm"
    network_id = "${var.network_id}"
    mac        = "${var.network_mac}"
    addresses  = ["${var.network_address}"]
  }
  # IMPORTANT: this is a known bug on cloud images, since they expect a console
  # we need to pass it
  # https://bugs.launchpad.net/cloud-images/+bug/1573095
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    file = "/home/tsweets/projects/devbox/downloads/proxmox-ve_7.0-2.iso"
  }

  disk {
    volume_id = libvirt_volume.proxmox_boot.id
  }

  disk {
    volume_id = libvirt_volume.proxmox_data.id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }

  boot_device {
    dev = ["hd","cdrom"]
  }
}
