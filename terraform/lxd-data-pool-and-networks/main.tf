resource "lxd_storage_pool" "data" {
  name   = "data"
  driver = var.data_pool.driver
  source = var.data_pool.source
}

resource "lxd_network" "networks" {
  for_each = { for net in var.networks : net.name => net }

  name = each.key
  config = {
    "ipv4.address" = join("/", [
      each.value.gateway_ip,
      split("/", each.value.cidr)[1]
    ])
    "ipv4.dhcp"    = false
    "ipv4.nat"     = true
    "ipv6.address" = "none"
    "ipv6.dhcp"    = false
    "ipv6.nat"     = true
    "dns.mode"     = "none"
  }
}
