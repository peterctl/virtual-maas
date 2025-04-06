variable "networks" {
  type = list(object({
    name       = string
    cidr       = string
    gateway_ip = string
  }))
}

variable "data_pool" {
  type = object({
    driver = string
    source = string
  })
}
