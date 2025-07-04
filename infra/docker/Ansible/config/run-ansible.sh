#!/bin/bash
# run-ansible.sh - Entrypoint for running all Ansible playbooks inside the ansible-runner container
set -e

export ANSIBLE_CONFIG=/ansible/playbooks/ansible.cfg

# Run main deployment playbook
ansible-playbook /ansible/playbooks/scripts/deployment/deploy.yml -i /ansible/playbooks/inventory.ini --extra-vars "ansible_become_pass=$ANSIBLE_BECOME_PASS"

# Run hardening playbook
ansible-playbook /ansible/playbooks/scripts/security/vagrant-hardening.yml -i /ansible/playbooks/inventory.ini --extra-vars "ansible_become_pass=$ANSIBLE_BECOME_PASS"

# End of script
