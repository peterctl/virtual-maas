#!/bin/bash

DELETE_VOLUMES=${DELETE_VOLUMES:-false}

read -r -d '' USERDATA <<EOF
#cloud-config

apt_update: true
apt_upgrade: true
packages:
- git
- ansible

fs_setup:
- label: data
  filesystem: ext4
  device: /dev/vdb
  partition: auto

mounts:
- [ "/dev/vdb", "/data", "ext4", "defaults,nofail", "0", "2" ]

swap:
  filename: /data/swapfile
  size: 17179869184     # 16*(1024**3): 16GB as bytes
  maxsize: 17179869184  # 16*(1024**3): 16GB as bytes

ssh_import_id: [${USER}]
EOF

vm_name=${USER}-virtual-maas

case "$1" in
create)
  image=$(
    openstack image list -f value -c Name |
      grep auto-sync/ubuntu | grep amd64 | grep noble | head -n1
  )

  server_create=$(
    openstack server create "$vm_name" --wait -f json \
      --image "$image" \
      --network "net_stg-reproducer-${USER}-psd" \
      --flavor staging-cpu48-ram64-disk100 \
      --user-data <(echo "$USERDATA") \
      --block-device device_name=data,destination_type=volume,device_type=disk,volume_size=500
  )
  exitcode=$?
  if [[ $exitcode != 0 ]]; then
    exit $exitcode
  fi

  server_id=$(echo "$server_create" | jq -r '.id')
  ip_addr=$(echo "$server_create" | jq -r '.addresses[][]')

  echo "VM $vm_name ($server_id) created successfully."
  echo "You can now SSH into it:"
  echo "    ssh ubuntu@$ip_addr"
  ;;
delete)
  server_json=$(openstack server show "$vm_name" -f json)
  server_id=$(echo "$server_json" | jq -r '.id')
  server_volumes=$(echo "$server_json" | jq -r '.volumes_attached[].id')

  openstack server delete "$server_id"

  echo "VM $vm_name ($server_id) has been deleted."
  if [[ "$DELETE_VOLUMES" == "true" ]]; then
    for volume in $server_volumes; do
      openstack volume delete "$volume"
      echo "Deleted attached volume $volume"
    done
  else
    echo "Please delete the attached volumes manually:"
    for volume in $server_volumes; do
      echo "    openstack volume delete $volume"
    done
  fi
  ;;
"show-ip")
  server_json=$(openstack server show "$vm_name" -f json)
  ip_addr=$(echo "$server_json" | jq -r '.addresses[][]')
  echo "$ip_addr"
  ;;
*)
  echo "usage: $0 (create|delete|show-ip)"
  exit 1
  ;;
esac
