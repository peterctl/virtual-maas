#!/bin/bash -x

source init.sh

sudo systemctl disable --now systemd-timesyncd

ip_addr=$(
	ip -4 -br address show dev eth0 |
		awk '{print $3}' | cut -d/ -f1
)
maas_url="http://${ip_addr}:5240/MAAS"
sudo maas init region+rack --maas-url "$maas_url" --database-uri maas-test-db:///

PASSWORD=password
sudo maas createadmin \
	--username $MAAS_USER \
	--email ${MAAS_USER}@${MAAS_SERVER} \
	--ssh-import $SSH_KEY_REF \
	--password $PASSWORD
echo "$PASSWORD" >${OUT_DIR}/${MAAS_USER}-password.txt

maas_url=$(sudo maas config | awk -F = '$1=="maas_url" {print $2}')
admin_api_key=$(sudo maas apikey --generate --username $MAAS_USER)
echo "$admin_api_key" >${OUT_DIR}/${MAAS_USER}-api-key.txt
sudo maas login $MAAS_USER $maas_url $admin_api_key

export SUBNET=10.10.10.0/24
export FABRIC_ID=$(sudo maas admin subnet read "$SUBNET" | jq -r ".vlan.fabric_id")
export VLAN_TAG=$(sudo maas admin subnet read "$SUBNET" | jq -r ".vlan.vid")
export PRIMARY_RACK=$(sudo maas admin rack-controllers read | jq -r ".[] | .system_id")
sudo maas admin subnet update $SUBNET gateway_ip=10.10.10.1
sudo maas admin ipranges create type=dynamic start_ip=10.10.10.200 end_ip=10.10.10.254
sudo maas admin vlan update $FABRIC_ID $VLAN_TAG dhcp_on=True primary_rack=$PRIMARY_RACK
sudo maas admin maas set-config name=upstream_dns value=8.8.8.8

sudo maas admin sshkeys create key="$(cat ~/.ssh/id_rsa.pub)"
