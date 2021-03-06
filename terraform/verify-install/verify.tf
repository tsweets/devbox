# Note install provider in ~/.terraform.d/plugins/registry.terraform.io/hashicorp/libvirt/0.6.3/linux_amd64
# Will need to download from github and compile
# Make sure on ubuntu set security_driver = "none" in /etc/libvirtd/qemu.conf
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

resource "libvirt_pool" "ubuntu" {
  name = "ubuntu"
  type = "dir"
  path = "/tmp/terraform-provider-libvirt-pool-ubuntu"
}

resource "libvirt_volume" "centos7-qcow2" {
  name = "centos7.qcow2"
  pool   = libvirt_pool.ubuntu.name
  #source = "https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2"
  source = "../../downloads/CentOS-7-x86_64-GenericCloud.qcow2"
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
    volume_id = libvirt_volume.centos7-qcow2.id
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