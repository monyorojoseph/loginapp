output "admin-pip" {
  value = module.vm-01.vm_public_ip
}
output "manager-one-pip" {
  value = module.vm-02.vm_public_ip
}
output "manager-two-pip" {
  value = module.vm-03.vm_public_ip
}
output "worker-one-pip" {
  value = module.vm-04.vm_public_ip
}
output "worker-two-pip" {
  value = module.vm-05.vm_public_ip
}
output "worker-three-pip" {
  value = module.vm-06.vm_public_ip
}
output "worker-four-pip" {
  value = module.vm-07.vm_public_ip
}