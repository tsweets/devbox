variable "cluster_server_name" {
  description = "The Name of the cluster server"
  type = string
}

variable "boot_disk_size" {
  description = "Size of the boot disk in MB"
  type = number
}

variable "data_disk_size" {
  description = "Size of the boot disk in MB"
  type = number
}

variable "network_id" {
  description = "Network ID of the Lab"
  type = string
}

variable "pool_cluster_name" {
  description = "Name of the Disk Pool"
  type = string
}

variable "network_mac" {
  description = "MAC Address for VM"
  type = string
}

variable "network_address" {
  description = "IP Address for VM"
  type = string
}
