# Create resource group that will be used with Jenkins deploy
resource "azurerm_resource_group" "jenkins" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
}

# Create public IPs
resource "azurerm_public_ip" "jenkins" {
    name                         = "${var.computer_name}-pubip"
    location                     = "${azurerm_resource_group.jenkins.location}"
    resource_group_name          = "${azurerm_resource_group.jenkins.name}"
    public_ip_address_allocation = "static"
}

# Create virtual NIC that will be used with our Jenkins instance.
resource "azurerm_network_interface" "jenkins" {
  name                = "${azurerm_resource_group.jenkins.name}-nic"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.jenkins.name}"

  ip_configuration {
    name                          = "${var.computer_name}-ipconf"
    subnet_id                     = "${var.subnet_id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${element(azurerm_public_ip.jenkins.*.id, count.index)}"
  }
}

# STORAGE =======================================
# resource "azurerm_storage_account" "test" {
#   name                     = "${var.storageaccount}"
#   resource_group_name      = "${azurerm_resource_group.jenkins.name}"
#   location                 = "${var.location}"
#   account_tier             = "Standard"
#   account_replication_type = "LRS"
# }

# resource "azurerm_storage_container" "test" {
#   name                  = "vhds"
#   resource_group_name   = "${azurerm_resource_group.jenkins.name}"
#   storage_account_name  = "${azurerm_storage_account.test.name}"
#   container_access_type = "private"
# }

# VIRTUAL MACHINE ================================
resource "azurerm_virtual_machine" "chef_server" {
  name                  = "${var.computer_name}"
  location              = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.jenkins.name}"
  network_interface_ids = ["${azurerm_network_interface.jenkins.id}"]
  vm_size               = "${var.vm_size}"

  storage_image_reference {
    publisher = "${var.publisher}"
    offer     = "${var.offer}"
    sku       = "${var.sku}"
    version   = "${var.version}"
  }

  storage_os_disk {
    name          = "${var.computer_name}-osdisk"
    caching       = "ReadWrite"
    create_option = "FromImage"
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = "100"
    os_type           = "linux"
  }
  # storage_os_disk {
  #   name          = "${var.computer_name}-osdisk"
  #   vhd_uri       = "${azurerm_storage_account.test.primary_blob_endpoint}${azurerm_storage_container.test.name}/${var.computer_name}-osdisk.vhd"
  #   caching       = "ReadWrite"
  #   create_option = "FromImage"
  # }

  os_profile {
    computer_name  = "${var.computer_name}"
    admin_username = "${var.admin_user}"
    admin_password = "${var.admin_password}"
  }
  
  os_profile_linux_config {
    disable_password_authentication = false
      ssh_keys {
        path = "/home/${var.admin_user}/.ssh/authorized_keys"
        key_data = "${file("~/.ssh/id_rsa.pub")}"
    }
  }

  connection {
      type = "ssh"
      host = "${element(azurerm_public_ip.jenkins.*.ip_address, count.index)}"
      user = "${var.admin_user}"
      # password = "${var.admin_password}"
      private_key = "${file("~/.ssh/id_rsa")}"
      agent = false
  }

  provisioner "local-exec" {
       command = "echo 'sleeping'"
  }
  provisioner "local-exec" {
       command = "sleep 220"
  }
  provisioner "local-exec" {
       command = "echo 'done sleeping'"
  }
  provisioner "file" {
    source      = "json/stuff_and_things.json"
    destination = "/tmp/stuff_and_things.json"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install git -y",
      "sudo curl --connect-timeout 60 -L https://www.chef.io/chef/install.sh | sudo bash",
      "sudo mkdir -p /var/chef/cache /var/chef/cookbooks",
      "sudo git clone https://scott_flaherty:Grad_2155@bitbucket.org/trekbikes/cb_dvo_chefserver.git /var/chef/cookbooks/cb_dvo_chefserver",
      "sudo wget -qO- https://supermarket.chef.io/cookbooks/chef-server/versions/5.4.0/download |sudo tar xvzC /var/chef/cookbooks",
      "sudo wget -qO- https://supermarket.chef.io/cookbooks/chef-ingredient/versions/1.1.0/download |sudo tar xvzC /var/chef/cookbooks",
      "sudo wget -qO- https://supermarket.chef.io/cookbooks/chef-server-backup/versions/0.2.1/download |sudo tar xvzC /var/chef/cookbooks",
      "sudo wget -qO- https://supermarket.chef.io/cookbooks/cron/versions/1.7.6/download |sudo tar xvzC /var/chef/cookbooks",
      "sudo wget -qO- https://supermarket.chef.io/cookbooks/sysctl/versions/0.9.0/download |sudo tar xvzC /var/chef/cookbooks",
      "sudo wget -qO- https://supermarket.chef.io/cookbooks/ohai/versions/5.2.0/download |sudo tar xvzC /var/chef/cookbooks",
      "sudo mv /var/chef/cookbooks/cb_dvo_chefserver/data_bags /var/chef/",
      "sudo mv /tmp/stuff_and_things.json /var/chef/cache/stuff_and_things.json",
      "sudo chef-solo -j '/var/chef/cache/stuff_and_things.json' -o 'recipe[cb_dvo_chefserver::default]'"
    ]
  }
}
