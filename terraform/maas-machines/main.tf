resource "maas_vm_host_machine" "vms" {
  count = var.vm_count

  vm_host = var.maas_vm_host_id

  hostname = "${var.vm_hostname_prefix}-${count.index}"
  cores = 4
  memory = 16384

  dynamic "network_interfaces" {
    for_each = var.vm_networks

    content {
      name = "eth_${network_interfaces.value.name}"
      subnet_cidr = network_interfaces.value.cidr
    }
  }

  # For the root disk
  storage_disks {
    size_gigabytes = 100
  }

  # For Ceph OSDs
  storage_disks {
    size_gigabytes = 30
  }
}

resource "maas_tag" "tags" {
  for_each = toset(var.vm_tags)

  name = each.key
  machines = [ for vm in maas_vm_host_machine.vms : vm.id ]
}
