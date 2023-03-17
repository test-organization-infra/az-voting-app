variable "location" {
  default = "eastus"
}
variable "name" {
  default = "example"
}
variable "sku" {
  default = "Basic"
}
variable "dns_prefix" {
  default = "vote-aks"
}
variable "vm_size" {
  default = "Standard_D2_v2"
}
variable "type"{
  default = "SystemAssigned"
}