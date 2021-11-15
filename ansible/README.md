### Run Playbook
ansible-playbook -i hosts.ini bootstrap.yml

### Molecule Cheat Sheet
#### Create new role
```
molecule init role certificate-authority
```

Then copy an existing config

https://molecule.readthedocs.io
- molecule create
- molecule converge
- molecule login
- molecule destroy