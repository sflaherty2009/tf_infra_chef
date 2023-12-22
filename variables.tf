variable "location" {
  default = "eastus2"
}
variable "publisher" {
  default = "Canonical"
}
variable "offer" {
  default = "UbuntuServer"
}
variable "sku" {
  default = "16.04-LTS"
}
variable "version" {
  default = "latest"
}
variable "vm_size" {
  default = "Standard_A2"
}
variable "subnet_id" {
    default = "/subscriptions/9fbf7025-df40-4908-b7fb-a3a2144cee91/resourceGroups/AZ-RG-Network/providers/Microsoft.Network/virtualNetworks/AZ-VN-EastUS2-02/subnets/AZ-SN-dvo"
}
# CHEF
variable "chef_resource_group_name" {
  default = "AZL-ChefServer-02"
}
variable "chef_admin_password" {
  default = "ZyADTVd64swkdvfHFMeR"
}
variable "chef_admin_user" {
  default = "devops"
}
variable "chef_computer_name" {
  default = "azl-chef-02"
}
# AUTOMATE 
variable "auto_resource_group_name" {
  default = "azl-auto-01"
}
variable "auto_admin_password" {
  default = "ZyADTVd64swkdvfHFMeR"
}
variable "auto_admin_user" {
  default = "devops"
}
variable "auto_computer_name" {
  default = "azl-auto-01"
}
