# source blocks configure your builder plugins; your source is then used inside
# build blocks to create resources. A build block runs provisioners and
# post-processors on an instance created by the source.
source "virtualbox-iso" "devbox" {
    guest_os_type = "Ubuntu_64"
    iso_url = "/Users/tsweets/Downloads/ubuntu-20.04.2-live-server-amd64.iso"
    iso_checksum = "sha256:d1f2bf834bbe9bb43faf16f9be992a6f3935e65be0edece1dee2aa6eb1767423"
  #  iso_url = "/Users/tsweets/Downloads/ubuntu-20.10-live-server-amd64.iso"
  #  iso_checksum = "sha256:defdc1ad3af7b661fe2b4ee861fb6fdb5f52039389ef56da6efc05e6adfe3d45"
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



 