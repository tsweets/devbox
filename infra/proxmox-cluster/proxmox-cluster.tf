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

locals {
  # 10GB
  boot_disk_size = 10000000000  
  # 100GB
  data_disk_size = 100000000000
}
resource "libvirt_network" "lab_network" {
  # the name used by libvirt
  name = "prox-net"
  # mode can be: "nat" (default), "none", "route", "bridge"
  mode = "nat"
  #  the domain used by the DNS server in this network
  domain = "vlab.skyline.lan"
  #  list of subnets the addresses allowed for domains connected
  # also derived to define the host addresses
  # also derived to define the addresses served by the DHCP server
  addresses = ["172.20.0.0/24"]
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
    local_only = true
    # (Optional) one or more DNS forwarder entries.  One or both of
    # "address" and "domain" must be specified.  The format is:
    # forwarders {
    #     address = "my address"
    #     domain = "my domain"
    #  }
    #

    # (Optional) one or more DNS host entries.  Both of
    # "ip" and "hostname" must be specified.  The format is:
    hosts  {
      hostname = "test-vm"
      ip = "172.20.0.25"
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
module "pve-cluster-core" {
  source = "./pve-cluster-server"
  cluster_server_name = "core-services"
  boot_disk_size = local.boot_disk_size
  data_disk_size = local.data_disk_size
  network_id = libvirt_network.lab_network.id
  network_mac = "52:54:00:62:ec:00"
  network_address = "172.20.0.10"
  pool_cluster_name = libvirt_pool.cluster.name
}


# Proxmox Always on Server
module "pve-cluster-server-always-on" {
  source = "./pve-cluster-server"
  cluster_server_name = "proxmox-always-on"
  boot_disk_size = local.boot_disk_size
  data_disk_size = local.data_disk_size
  network_id = libvirt_network.lab_network.id
  network_mac = "52:54:00:62:ec:d0"
  network_address = "172.20.0.20"
  pool_cluster_name = libvirt_pool.cluster.name
}

# Proxmox Backup Server
module "pve-cluster-server-backup-recovery" {
  source = "./pve-cluster-server"
  cluster_server_name = "proxmox-backup-recovery"
  boot_disk_size = local.boot_disk_size
  data_disk_size = local.data_disk_size
  network_id = libvirt_network.lab_network.id
  network_mac = "52:54:00:62:ec:d1"
  network_address = "172.20.0.21"
  pool_cluster_name = libvirt_pool.cluster.name
}

# Proxmox Cluster Server 1
module "pve-cluster-server-cluster-1" {
  source = "./pve-cluster-server"
  cluster_server_name = "proxmox-cluster-1"
  boot_disk_size = local.boot_disk_size
  data_disk_size = local.data_disk_size
  network_id = libvirt_network.lab_network.id
  network_mac = "52:54:00:62:ec:d2"
  network_address = "172.20.0.22"
  pool_cluster_name = libvirt_pool.cluster.name
}

# Proxmox Cluster Server 2
module "pve-cluster-server-cluster-2" {
  source = "./pve-cluster-server"
  cluster_server_name = "proxmox-cluster-2"
  boot_disk_size = local.boot_disk_size
  data_disk_size = local.data_disk_size
  network_id = libvirt_network.lab_network.id
  network_mac = "52:54:00:62:ec:d3"
  network_address = "172.20.0.23"
  pool_cluster_name = libvirt_pool.cluster.name
}

# Proxmox Cluster Server 3
module "pve-cluster-server-cluster-3" {
  source = "./pve-cluster-server"
  cluster_server_name = "proxmox-cluster-3"
  boot_disk_size = local.boot_disk_size
  data_disk_size = local.data_disk_size
  network_id = libvirt_network.lab_network.id
  network_mac = "52:54:00:62:ec:d4"
  network_address = "172.20.0.24"
  pool_cluster_name = libvirt_pool.cluster.name
}

