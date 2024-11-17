# MAAS Test Environment

This repository contains the necessary automation scripts to deploy:

- A MAAS server.
- An LXD daemon registered in the MAAS server as a VM host.
- The proper networking configurations to allow VM connectivity.
- A Juju controller running on a MAAS-provisioned VM.

## Usage

Clone the repo.

```bash
git clone https://github.com/peterctl/virtual-maas
cd virtual-maas
```

Install dependencies.

```bash
sudo apt update
sudo apt install ansible
```

Modify `variables.yaml` as needed.

Run the playbook.

```bash
ansible-playbook deploy-environment.yaml -i inventory.yaml -e @variables.yaml
```

After the playbook completes, MAAS should be ready to create VMs, and Juju
should be ready to deploy models.
