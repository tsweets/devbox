terraform {
 required_version = ">= 0.13"
  required_providers {
    libvirt = {
     # version = "18c5352b9f9315f1b31a519b4ccfe255cdf166a3-dirty"
      source  = "dmacvicar/libvirt"
    }
  }
}


# instance the provider
provider "libvirt" {
  uri = "qemu:///system"
}

locals {
  # 10GB
  boot_disk_size = 10000000000  
  # 100GB
  data_disk_size = 100000000000
}
### NOTE: version .7 of the provider has a network v2 resource that has dhcp options for start/end range. Looks like it also have static ips as well. I need that.
resource "libvirt_network_v2" "public_lab_network" {
  # the name used by libvirt
  name = "lab-public-net"
  autostart = true
  # mode can be: "nat" (default), "none", "route", "bridge"
  forward {
    mode = "nat"
  }

  #  the domain used by the DNS server in this network
  domain {
    name = "devlab.skyline.lan"
    local_only = true
  }
  #  list of subnets the addresses allowed for domains connected
  # also derived to define the host addresses
  # also derived to define the addresses served by the DHCP server
  #addresses = ["172.17.0.0/24"]
  ip {
      address = "172.17.0.1"
      netmask = "255.255.255.0"
    dhcp {
     host {
       name = "gateway"
       mac  = "52:54:00:62:ed:d0"
       ip   = "172.17.0.2"
     }
     range {
        start = "172.17.0.200"
        end = "172.17.0.250"
      }
    }
  }
  # (Optional) DNS configuration
  dns {
    # (Optional, default false)
    # Set to true, if no other option is specified and you still want to
    # enable dns.
    enabled = true
    # (Optional, default false)
    # true: DNS requests under this domain will only be resolved by the
    # virtual network's own DNS server
    # false: Unresolved requests will be forwarded to the host's
    # upstream DNS server if the virtual network's DNS server does not
    # have an answer.
    #local_only = true
    # (Optional) one or more DNS forwarder entries.  One or both of
    # "address" and "domain" must be specified.  The format is:
    # forwarders {
    #     address = "my address"
    #     domain = "my domain"
    #  }
    #

    # (Optional) one or more DNS host entries.  Both of
    # "ip" and "hostname" must be specified.  The format is:
    host  {
      hostname = "gateway"
      ip = "172.17.0.2"
    }
    # hosts {
    #     hostname = "my_hostname"
    #     ip = "my.ip.address.2"
    #   }
    #

    # (Optional) one or more static routes.
    # "cidr" and "gateway" must be specified. The format is:
    # routes {
    #     cidr = "10.17.0.0/16"
    #     gateway = "10.18.0.2"
    #   }
  }

}


resource "libvirt_network_v2" "private_lab_network" {
  name      = "lab-private-net"
  autostart = true
  #mode      = "none"
  domain {
    name = "vlab.skyline.lan"
    local_only = true
  }
  ip {
    address = "172.20.0.0"
    netmask = "255.255.255.0"
    dhcp {
      host {
        name = "gateway"
        mac  = "52:54:00:62:ec:d0"
        ip   = "172.20.0.2"
      }

      host {
        name = "workstation"
        mac  = "52:54:00:62:ec:d1"
        ip   = "172.20.0.5"
      }

      host {
        name = "pve-core"
        mac  = "52:54:00:62:ec:d2"
        ip   = "172.20.0.10"
      }

      range {
        start = "172.20.0.200"
        end = "172.20.0.250"
      }
    }
  }
 # route {
  #  address = "0.0.0.0"
  #  prefix = "24"
#    gateway = "172.20.0.2"
 # }
  #<route address="192.168.222.0" prefix="24" gateway="192.168.122.2"/>


}
resource "libvirt_pool" "cluster" {
  name = "cluster"
  type = "dir"
  path = "/mnt/data/terraform"
}


#resource "libvirt_volume" "ubuntu-qcow2" {
#  name   = "ubuntu-qcow2"
#  pool   = libvirt_pool.cluster.name
#  source = "/home/tsweets/projects/devbox/downloads/ubuntu-20.04-server-cloudimg-amd64.img"
#  format = "qcow2"
#}



# data "template_file" "network_config" {
#   template = file("${path.module}/network_config.cfg")
# }

# Core Services Server (ie DNS, LDAP)

resource "libvirt_volume" "vm_gateway_boot" {
  name          = "vm_gateway_boot"
  # 10GB
  size          = 10000000000
  pool          = "cluster"
}

resource "libvirt_volume" "vm_workstation_boot" {
  name          = "vm_workstation_boot"
  # 20GB
  size          = 20000000000
  pool          = "cluster"
}

resource "libvirt_volume" "vm_core_boot" {
  name          = "vm_core_boot"
  # 50GB
  size          = 50000000000
  pool          = "cluster"
}

resource "libvirt_volume" "vm_nas_zero_boot" {
  name          = "vm_nas_zero_boot"
  # 10GB
  size          = 10000000000
  pool          = "cluster"
}
resource "libvirt_volume" "vm_nas_zero_data1" {
  name          = "vm_nas_zero_data1"
  # 50GB
  size          = 50000000000
  pool          = "cluster"
}
resource "libvirt_volume" "vm_nas_zero_data2" {
  name          = "vm_nas_zero_data2"
  # 50GB
  size          = 50000000000
  pool          = "cluster"
}


resource "libvirt_domain" "vm-gateway" {
  name   = "gateway"
  memory = "1024"
  vcpu   = 1


  network_interface {
    hostname   = "gateway.devlab.skyline.lan"
    network_id = libvirt_network_v2.private_lab_network.id
    mac        = "52:54:00:62:ec:d0"
    addresses  = ["172.20.0.2"]
  }

  network_interface {
    hostname   = "gateway.vlab.skyline.lan"
    network_id = libvirt_network_v2.public_lab_network.id
    mac        = "52:54:00:62:ed:d0"
   # addresses  = ["172.17.0.1"]
  }

  disk {
    file = "/home/tsweets/projects/devbox/downloads/pfSense-CE-2.5.2-RELEASE-amd64.iso"
  }

  disk {
    volume_id = libvirt_volume.vm_gateway_boot.id
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

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

resource "libvirt_domain" "vm-workstation" {
  name   = "workstation"
  memory = "8200"
  vcpu   = 2


  network_interface {
    hostname   = "workstation.devlab.skyline.lan"
    network_id = libvirt_network_v2.private_lab_network.id
    mac        = "52:54:00:62:ec:d1"
  }


  disk {
    file = "/home/tsweets/projects/devbox/downloads/pop-os_21.04_amd64_intel_10.iso"
  }

  disk {
    volume_id = libvirt_volume.vm_workstation_boot.id
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

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

resource "libvirt_domain" "vm-core" {
  name   = "core"
  memory = "4000"
  vcpu   = 2


  network_interface {
    hostname   = "pve-core.devlab.skyline.lan"
    network_id = libvirt_network_v2.private_lab_network.id
    mac        = "52:54:00:62:ec:d2"
  }


  disk {
    file = "/home/tsweets/projects/devbox/downloads/proxmox-ve_7.0-2.iso"
  }

  disk {
    volume_id = libvirt_volume.vm_core_boot.id
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

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

resource "libvirt_domain" "vm-nas-zero" {
  name   = "nas-zero"
  memory = "4000"
  vcpu   = 2


  network_interface {
    hostname   = "pve-core.devlab.skyline.lan"
    network_id = libvirt_network_v2.private_lab_network.id
    mac        = "52:54:00:62:ec:d3"
  }


  disk {
    file = "/home/tsweets/projects/devbox/downloads/TrueNAS-SCALE-22.02-RC.1-2.iso"
  }

  disk {
    volume_id = libvirt_volume.vm_nas_zero_boot.id
  }
  disk {
    volume_id = libvirt_volume.vm_nas_zero_data1.id
  }
  disk {
    volume_id = libvirt_volume.vm_nas_zero_data2.id
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

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

