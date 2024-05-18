variable "inbound_ports" {
  type = list(object({ name = string, port = string, priority = string }))
  default = [
    {
      name     = "ssh"
      port     = "22"
      priority = "300"
    },
    {
      name     = "http"
      port     = "80"
      priority = "301"
    },
    {
      name     = "https"
      port     = "443"
      priority = "302"
    },
    {
      name     = "promethesu"
      port     = "9090"
      priority = "303"
    },
    {
      name     = "grafana"
      port     = "3000"
      priority = "304"
    }
  ]
}