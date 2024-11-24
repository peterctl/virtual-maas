variable "maas_api_url" {
  type = string
}

variable "maas_api_key" {
  type = string
}

variable "maas_vm_host_id" {
  type = string
}

variable "machines" {
  type = list(object({
    name = string
    cores = number
    memory_mb = number
    networks = list(string)
    tags = optional(list(string))
    disks = optional(list(object({
      size_gb = number
    })))
  }))
}

variable "networks" {
  type = list(object({
    name = string
    cidr = string
  }))
}
