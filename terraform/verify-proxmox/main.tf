
terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
    }
  }
}
provider "proxmox" {
    pm_tls_insecure = true
    pm_api_url = "https://pve-proto.cloud.skyline.lan:8006/api2/json"
    pm_password = <PASSWD from env>
    pm_user = "root@pam"
  #  pm_otp = ""
  #  pm_api_token_id = "user"
  #  pm_api_token_secret="secret"
}


resource "proxmox_vm_qemu" "example" {
    name = "servy-mcserverface"
    desc = "A test for using terraform and vagrant"
    target_node = "pve-proto"
    iso = "local:iso/ubuntu-20.04.3-live-server-amd64.iso"
    os_type = "cloud-init"
    cores = 2
    sockets = 1
    vcpus = 0
    cpu = "host"
    memory = 2048
    scsihw = "lsi"

    clone = "VM-9001"


    disk {
        size = "8G"
        type = "virtio"
        storage = "data-1"
    }

    network {
        model = "virtio"
        bridge = "vmbr0"
    }

    # Try using a custom cloud init config
    # /var/lib/vz/snippets
    cicustom = "user=local:snippets/cloud-config.yml"
    #ciuser = "ubuntu"
    #cipassword = "password"
    ipconfig0 = "ip=dhcp"

}

