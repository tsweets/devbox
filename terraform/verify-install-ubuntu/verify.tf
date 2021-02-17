# Note install provider in ~/.terraform.d/plugins/registry.terraform.io/hashicorp/libvirt/0.6.3/linux_amd64
# Will need to download from github and compile
terraform {
  required_providers {
    libvirt = {
      source  = "libvirt"
      version = "0.6.3"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_volume" "ubuntu20-04" {
  name = "ubuntu20-04"
  pool = "default"
  #source = "https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64-disk-kvm.img"
  source = "../../downloads/ubuntu-20.04-server-cloudimg-amd64-disk-kvm.img"
  format = "qcow2"
}

# Define KVM domain to create
resource "libvirt_domain" "test" {
  name   = "test"
  memory = "1024"
  vcpu   = 1

  network_interface {
    network_name = "default"
  }

  disk {
    volume_id = "libvirt_volume.ubuntu20-04.id"
  }

  console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }
}