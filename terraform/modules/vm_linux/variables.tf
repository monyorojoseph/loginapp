variable "resource_group_name" {}
variable "location" {}
variable "subnet_id" {}
variable "vm_name" {}
variable "vm_size" {
  type    = string
  default = "Standard_B2ats_v2" # "Standard_B1ms" # Standard_B2ls_v2 # Standard_B2s_v2
}
variable "admin_username" {
  type    = string
  default = "azureuser"
}