terraform {
 required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
    }
  }
}

# instance the provider
provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_pool" "cluster" {
  name = "cluster"
  type = "dir"
  path = "/mnt/data/terraform"
}

# We fetch the latest ubuntu release image from their mirrors
# resource "libvirt_volume" "ubuntu-qcow2" {
#   name   = "ubuntu-qcow2"
#   pool   = libvirt_pool.ubuntu.name
#   #source = "https://cloud-images.ubuntu.com/releases/xenial/release/ubuntu-16.04-server-cloudimg-amd64-disk1.img"
#   #source = "https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64-disk-kvm.img"
#   source = "https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64.img"
#   format = "qcow2"
# }


# volumes to attach to the proxmox servers (10GB)
resource "libvirt_volume" "proxmox_boot" {
  name          = "proxmox_boot"
  size          = 10000000000
  pool          = libvirt_pool.cluster.name
}

# volumes to attach to the proxmox servers (10GB)
resource "libvirt_volume" "proxmox_data" {
  name          = "proxmox_data"
  size          = 10000000000
  pool          = libvirt_pool.cluster.name
}


# data "template_file" "network_config" {
#   template = file("${path.module}/network_config.cfg")
# }


# Create the machine
resource "libvirt_domain" "promox-support" {
  name        = "proxmox-support"
  description = "Always on Support Server"
  memory      = "512"
  vcpu        = 1
  running     = "false"


  network_interface {
    network_name = "default"
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
}

# IPs: use wait_for_lease true or after creation use terraform refresh and terraform show for the ips of domain
