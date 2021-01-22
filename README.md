# devbox
### Install External Roles
ansible-galaxy install -r requirements.yml 

### Terraform
The terraform kvm is a little broken right now, but there are some work arounds to get it installed. 
Look at this bug.  

https://github.com/dmacvicar/terraform-provider-libvirt/issues/747

Download the CentOS qcow image, to <project root>/Downloads (Create this dir)

```
wget https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2
```

Terraform commands to know  
- terraform init (need to do this 1st)
- terraform plan (dry run - verify)
- terraform apply (run)
- terraform destroy


Notes:  
May have to start the default network (via VirtManager)

# Virtual Machines
## Infrastructure


# Services
## Certificate Authority
## LDAP


# Ansible
## Create new role
```
molecule init role certificate-authority
```

Then copy an existing config  

## Molecule Cheat Sheet
https://molecule.readthedocs.io
- molecule create
- molecule converge
- molecule login
- molecule destroy
