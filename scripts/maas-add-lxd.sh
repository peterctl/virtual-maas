#!/bin/bash

source init.sh

cat lxd.conf.yaml | sudo lxd init --preseed

IP_ADDR=$(ip -4 -br a | awk '$1!="lo" && $2=="UP" { print $3 }' | cut -d/ -f1)
lxd_remote_addr=$IP_ADDR:8443

maas_vmhost_json=$(
	sudo maas $MAAS_USER vm-hosts create \
		name=$MAAS_SERVER \
		type=lxd \
		project=$LXD_PROJECT \
		power_address=$lxd_remote_addr \
		password=password
)
maas_vmhost_id=$(echo "$maas_vmhost_json" | jq .id)
echo MAAS_VMHOST_ID=$maas_vmhost_id
