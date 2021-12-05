# Bootstrap Server
Also known as a "Deployment Server"   
This is the 1st server that is built up - without any domain dependencies and is "seeded" with data that is used to to deploy the rest of of the cloud

For example:
- Root Certificate
- SSH Keys
- VM Images


## General Idea
The deployment server will act as an archive of the data needed for the deployment. This archive will be dynamically via automation

### Base Services
- File Server (SMB and NFS)
- HTTP Server - will point to the same file share


### Project Directories
- ansible 
  - Contains playbook to create deployment server
- libvirt-tf (todo)
  - Contains terraform file to create server on libvirt
- proxmox-tf (todo)
  - Contains terraform file to create server on proxmox

### Ansible Information
#### Run Playbook
ansible-playbook -i hosts.ini bootstrap.yml

#### Molecule Cheat Sheet
##### Create new role
```
molecule init role certificate-authority -d docker
```

Then copy an existing config

https://molecule.readthedocs.io
- molecule create
- molecule converge
- molecule login
- molecule destroy