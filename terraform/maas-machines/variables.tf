variable "maas_api_url" {
  type = string
}

variable "maas_api_key" {
  type = string
}

variable "maas_vm_host_id" {
  type = string
}

variable "vm_count" {
  type = number
}

variable "vm_hostname_prefix" {
  type = string
}

variable "vm_networks" {
  type = list(object({
    name = string
    cidr = string
    gateway_ip = string
  }))
}

variable "vm_tags" {
  type = list(string)
}
