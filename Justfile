# Justfile

# Define the name of your Conda environment
CONDA_ENV_NAME := "ansible_dev"
docker_repo := "rudolffortes"

# default - list recipes
default: run
    @echo "#########################################"
    @echo "Please Specify a task:"
    @echo " -> just <recipe>            # run recipe"
    @echo " -> just -h, --help          # Print help information"
    @echo "#########################################"

# run list
[linux]
run:
    @just --list

# run - to be defined Windows
[windows]
run:
    @echo "to be defined for WINDOWS"

###############################################################################################
# Aliases - quick shortuts
###############################################################################################
alias playbooks:=playbook_list
alias environments:=environment_list
alias hosts:=host_list


###############################################################################################
# Ansible Playbooks
###############################################################################################
# run [playbook] classic : check inventory
play_legacy ssh_key='id_rsa_ansible' playbook='./site.yml' inventory='inventories/inventory_main.ini' flags='--check --diff':
    @echo "running playbook {{playbook}} against - {{inventory}}"
    @echo "debug - whoami= $(whoami)"
    @[ -e "{{playbook}}" ] || (echo "Error: Playbook {{playbook}} does not exist."; exit 1)
    @[ -e "{{inventory}}" ] || (echo "Error: Inventory {{inventory}} does not exist."; exit 1)
    @[ -e "/home/$(whoami)/.ssh/vault-password" ] || (echo "Error: Inventory {{inventory}} does not exist."; exit 1)
    @[ -e "/home/$(whoami)/.ssh/{{ssh_key}}" ] || (echo "Error: ssh_key {{ssh_key}} does not exist."; exit 1)
    ansible-playbook -i {{inventory}} {{playbook}} {{flags}}

# Ported from legacy script run_check_mode.sh
run_check_mode:
    @echo "running "
    @just check 'id_rsa_ansible' 'site.yml' 'inventories/inventory_main.ini'

# run [playbook] check against [environment]
play environment='linux' playbook='inventory_check.yml' flags='--check --diff':
    @echo "running playbook {{playbook}} against - {{environment}}"
    @[ -e "environment/{{environment}}" ] || (echo "Error: Environment {{environment}} does not exist."; exit 1)
    @[ -e "playbooks/{{playbook}}" ] || (echo "Error: Playbook {{playbook}} does not exist."; exit 1)
    ansible-playbook -i environment/{{environment}} playbooks/{{playbook}} {{flags}}

# list all environments
environment_list:
    @echo "Environments:"
    @find environment -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | tr '\n' ' ' && echo

# list all playbooks
playbook_list:
    @echo "Playbooks:"
    @find playbooks -mindepth 1 -maxdepth 1 -type f -exec basename {} \; | tr '\n' ' ' && echo

# list all hosts [host_vars host instances within all environment]
host_list:
    @echo "Hosts:"
    @ls environment/*/host_vars

#######################################
# Docker
#######################################
# docker build {{target}}
docker_build target='example':
    @echo "docker build - {{target}}"
    @[ -e ".devcontainer/{{target}}" ] || (echo "Error: Docker Path {{target}} does not exist."; exit 1)
    @docker build .devcontainer/{{target}} -t {{docker_repo}}/{{target}}

# docker run {{target}} 
docker_run target='example':
    @echo "docker build - {{target}}"
    @[ -e ".devcontainer/{{target}}" ] || (echo "Error: Docker Path {{target}} does not exist."; exit 1)
    @docker run -it --rm {{docker_repo}}/{{target}}

# list available docker recipes
docker_list:
    @echo "Docker recipes:"
    @find .devcontainer -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | tr '\n' ' ' && echo
