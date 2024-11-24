locals {
  machine_map = { for machine in var.machines : machine.name => machine }
  network_cidrs = { for network in var.networks : network.name => network.cidr }
}

resource "maas_vm_host_machine" "machines" {
  for_each = local.machine_map

  vm_host = var.maas_vm_host_id

  hostname = each.key
  cores    = each.value.cores
  memory   = each.value.memory_mb

  dynamic "network_interfaces" {
    for_each = toset(each.value.networks)
    content {
      name        = network_interfaces.key
      subnet_cidr = local.network_cidrs[network_interfaces.key]
    }
  }

  dynamic "storage_disks" {
    for_each = { for i, disk in each.value.disks : i => disk }
    content {
      size_gigabytes = storage_disks.value.size_gb
    }
  }
}

locals {
  all_tags     = distinct(flatten([for machine in var.machines : machine.tags]))
  tag_map = zipmap(
    local.all_tags,
    [
      for tag in local.all_tags : [
        for key, machine in local.machine_map :
        maas_vm_host_machine.machines[key].id if contains(machine.tags, tag)
      ]
    ]
  )
}

resource "maas_tag" "tags" {
  for_each = local.tag_map

  name     = each.key
  machines = each.value
}
