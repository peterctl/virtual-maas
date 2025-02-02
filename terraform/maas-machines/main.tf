locals {
  machine_map   = { for machine in var.machines : machine.name => machine }
  network_cidrs = { for network in var.networks : network.name => network.cidr }
  zones         = toset([for machine in var.machines : machine.zone if machine.zone != null])
}

# TODO: this currently depends on a fork of terraform-provider-maas.
#   https://github.com/peterctl/terraform-provider-maas
resource "maas_zone" "zones" {
  for_each = local.zones

  name = each.value
}

resource "maas_vm_host_machine" "machines" {
  for_each = local.machine_map

  vm_host = var.maas_vm_host_id

  hostname = each.key
  cores    = each.value.cores
  memory   = each.value.memory_mb
  zone     = each.value.zone

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
      pool           = storage_disks.value.pool
    }
  }

  depends_on = [maas_zone.zones]
}

locals {
  all_tags = distinct(flatten([for machine in var.machines : machine.tags]))
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
