# Example Dev Environment

This quick guide helps users start to use the devContainer for vscode.

## Start your workspace in a devcontainer

[pre-requisite] : "Dev Containers" extension installed

In vs code run the following command (Ctr+Shift+P):
- Dev Containers: Rebuild and Reopen in Container

For more information see:
https://code.visualstudio.com/docs/devcontainers/containers

See the .devcontainer/<example>/Dockerfile for implementation details
- you will get a fresh Ubuntu 22.04 Docker with miniconda installed and python 3.10 with tox installed. \
(subject to change based on the FROM: line in the docker file)


## Tooling available in the Dev Container

### Tox

Tox is a python test execution wrapper: 
to run tox you need to specify the following environment variable:
- PIP_EXTRA_INDEX_URL:\
PIP_EXTRA_INDEX_URL={$user}:{$PAT}@<your pypi repo>/api/pypi/pypi/simple

### Miniconda

Miniconda is a python wrapper that allows the user to controll their own python environment 
- for more information: 
  https://conda.io/projects/conda/en/latest/user-guide/cheatsheet.html

```r
$ conda env list
#-----------------------------------------
# conda environments:
#
base                  *  /opt/conda
your_env                 /opt/conda/envs/your_env
# the one with the asterix is the active one
```
```r
$ conda create --name your_env python=3.10
#-----------------------------------------
Solving environment: done
## Package Plan ##
  environment location: /opt/conda/envs/your_env
  added / updated specs:
    - python=3.10
#
# To activate this environment, use
#                                        
#     $ conda activate your_env          
# # To deactivate an active environment, use
#
#     $ conda deactivate
```

### Just

just is a simple command line executer to see the available list of actions please run - just \
@see https://github.com/casey/just for more information\
@see Justfile for implementation

- this is for local testing only do not use this tool in a pipeline
- to run just you need to create a .env file with the appropriate environment variables set:
    - PIP_EXTRA_INDEX_URL
this will retreive the pip.conf file into your docker by logging into azure_devops and filling in the details used in pipelines
```r
$> just
#########################################
Available recipes:
    default                       # default - list recipes
    docker_build target='example' # docker build {{target}}
    docker_list                   # list available docker recipes
    docker_run target='example'   # docker run {{target}}
    environment_list              # list all environments
    environments                  # alias for `environment_list`
    host_list                     # list all hosts [host_vars host instances within all environment]
    hosts                         # alias for `host_list`
    play environment='linux' playbook='inventory_check.yml' flags='--check --diff' # run [playbook] check against [environment]
    play_legacy ssh_key='id_rsa_ansible' playbook='./site.yml' inventory='inventories/inventory_main.ini' flags='--check --diff' # run [playbook] classic : check inventory
    playbook_list                 # list all playbooks
    playbooks                     # alias for `playbook_list`
    run                           # run list
    run_check_mode                # Ported from legacy script run_check_mode.sh
#########################################
Please Specify a task:
 -> just <recipe>                   # run recipe
 -> just -h, --help                 # Print help information
#########################################
```