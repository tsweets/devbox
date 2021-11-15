# source blocks configure your builder plugins; your source is then used inside
# build blocks to create resources. A build block runs provisioners and
# post-processors on an instance created by the source.
# packer build devbox.pkr.hcl

source "virtualbox-iso" "devbox" {
    guest_os_type = "Ubuntu_64"
    iso_url = "/home/tsweets/Downloads/ubuntu-20.04.3-live-server-amd64.iso"
    iso_checksum = "sha256:f8e3086f3cea0fb3fefb29937ab5ed9d19e767079633960ccb50e76153effc98"
    disk_size = 15000
    cpus = 2
    memory = 2048
    shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
    ssh_username = "ubuntu"
    ssh_password = "ubuntu"
    ssh_handshake_attempts = 50
    ssh_pty = true
    ssh_timeout = "20m"

    http_directory = "http"
    boot_wait = "5s"
    boot_command  = ["<enter><enter><f6><esc><wait> ", "autoinstall ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/", "<enter><wait>"]

  
}  

# a build block invokes sources and runs provisioning steps on them.
build {
    sources = ["sources.virtualbox-iso.devbox"]

    #provisioner "shell" {
    #    inline = ["ls /"]
    #}
    provisioner "shell" {
       execute_command = "echo 'ubuntu' | {{.Vars}} sudo -S -E bash '{{.Path}}'"
       script = "ansible.sh"
    }

   # provisioner "ansible" {
   #     playbook_file = "./helloworld-playbook.yml"
   #    # use_proxy = false
   #     user = "ubuntu"
   #     extra_arguments = [ "-vvvv" ]
   #     #      "ansible_env_vars": [ "ANSIBLE_HOST_KEY_CHECKING=False", "ANSIBLE_SSH_ARGS='-o ControlMaster=auto -o ControlPersist=60s'" ],
   # }

   provisioner "ansible-local" {
      playbook_file = "./helloworld-playbook.yml"
   }

    provisioner "shell" {
       execute_command = "echo 'ubuntu' | {{.Vars}} sudo -S -E bash '{{.Path}}'"
       script = "cleanup.sh"
    }

}



 