# Terraform for Infra only
Terraform to provision infra for random deployment tests on AWS

## Generate custom variables.tf
Custom config is defined in params.sh which is used by setup.sh to generate the variables.tf from a template file variables.tf.template

edit: params.sh
run ./setup.sh

check variables.tf is as required.

note: if you want to add variables you need to change the template and the setup script as well as adding them to the params.sh


## Setup and test terraform

note: I wrote and tested this with terraform v0.11

```
terraform init
terraform plan
```

## All looking good, then apply the terraform to deploy..

```
terraform apply
```

## check the terraform output variables are looking good
as they are used by later scripts to generate the config files for ansible..

```
terraform output
```

## Ansible to finish the infra config, deploy docker daemon and bits
First generate an ansible hosts file to use with the playbooks defined in the site.yml:
```
---

- hosts: all
  roles:
  - accept-host-keys
  - ntp
  - pre-deploy
  - firewall
  - docker-install
```
note: this script includes the params.sh so gets some of the variables directly from there, the rest are parsed from terraform output.

```
./generate-hosts-file.sh
```
check the generated hosts file and run the ansible playbook to finish the infra config..
You can see which hosts will be included and also which role tasks will be run from the ./roles directory;
```
ansible-playbook -i hosts -s site.yml --list-hosts
ansible-playbook -i hosts -s site.yml --list-tasks
ansible-playbook -i hosts -s site.yml --check
```

Run the config playbook, note that this also updates and reboots the instances so takes a while..
```
ansible-playbook -i hosts -s site.yml
```





