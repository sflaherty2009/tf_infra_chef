variable "resource_group_name" {
  default = "AZL-ChefServer-02-tst"
}
variable "storageaccount" {
  default = "chef2storagetst"
}
variable "location" {
  default = "eastus2"
}
# variable "publisher" {
#   default = "OpenLogic"
# }
variable "publisher" {
  default = "Canonical"
}
# variable "offer" {
#   default = "CentOS"
# }
variable "offer" {
  default = "UbuntuServer"
}
# variable "sku" {
#   default = "7.3"
# }
variable "sku" {
  default = "16.04-LTS"
}
variable "admin_password" {
  default = "ZyADTVd64swkdvfHFMeR"
}
variable "admin_user" {
  default = "devops"
}
variable "version" {
  default = "latest"
}
variable "computer_name" {
  default = "azl-chef-02-tst"
}
variable "vm_size" {
  default = "Standard_A2"
}
# this can be found using resource explorer in hte azure portal.  This one is Int-Mgmt
variable "subnet_id" {
    default = "/subscriptions/9fbf7025-df40-4908-b7fb-a3a2144cee91/resourceGroups/AZ-RG-Network/providers/Microsoft.Network/virtualNetworks/AZ-VN-EastUS2-02/subnets/AZ-SN-dvo"
}
variable "ssh_key_thumbprint" {
	default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDjSq6wA1WDmJnBEaiTJUk2wrqZ7OaeDR6VQ+xV5iShotocGzmgIuZSWNnG/eakio9V0dlBct1UcPSStUp4Xe1ii6EE114XyM41S65rjzBGU4akWVQYsdUlIZflok9r8kWV3OOp38kXFzMXW+suHCuUS6w+QyWbFnBUJdGBYya/+gpZ8LcudfQ9267A0SYk2uhKg2XpcwUUf6GomhQrtjlRVRMobwXvQHTMIR8i7M+AC7WIYIcYoEVyg3bCStdFlLivUICz+NV88heCqjDjk19ZUkgUyH4cyLNEJzsjPOXBlgs2+wny53AzeSzBzjrvmiq4bK5nBO48UfHBS4lMmjYx devops@WTLMLSFLAHERTY"
}
variable "subscription_id" {
  default = "9fbf7025-df40-4908-b7fb-a3a2144cee91"
}
