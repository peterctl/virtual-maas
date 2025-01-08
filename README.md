# MAAS Test Environment

This repository contains the necessary automation scripts to deploy:

- A MAAS server.
- An LXD daemon registered in the MAAS server as a VM host.
- The proper networking configurations to allow VM connectivity.
- A Juju controller running on a MAAS-provisioned VM.

## Usage on PS6 STG reproducer environments

If you do not have access to the SE cloud, or do not know what it is, you can
follow [the Support Engineering docs][se_cloud_docs] to get access.

Once you have access, you can create a beefy VM with the needed configs and
volumes using the helper script.

```bash
bash scripts/ps6-stg-reproducers-vm.sh up
```

SSH into the VM you just created.

```bash
vm_ip=$(bash scripts/ps6-stg-reproducers-vm.sh show-ip)
ssh ubuntu@$vm_ip
```

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
ansible-playbook deploy-environment.yaml \
  -i inventory.yaml \
  -e @reference-variables/ps6-stg-reproducers.yaml
```

After the playbook completes, MAAS should be ready to create VMs, and Juju
should be ready to deploy models.

[se_cloud_docs]: https://sites.google.com/canonical.com/support/support-labs/se-cloud
