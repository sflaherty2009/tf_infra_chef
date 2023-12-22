#### CHEF ####
# Create resource group that will be used with chef deploy
resource "azurerm_resource_group" "chef" {
  name     = "${var.chef_resource_group_name}"
  location = "${var.location}"
}

# Create public IPs
resource "azurerm_public_ip" "chef" {
    name                         = "${var.chef_computer_name}-pubip"
    location                     = "${azurerm_resource_group.chef.location}"
    resource_group_name          = "${azurerm_resource_group.chef.name}"
    allocation_method            = "public"
}

# Create virtual NIC that will be used with our chef instance.
resource "azurerm_network_interface" "chef" {
  name                = "${azurerm_resource_group.chef.name}-nic"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.chef.name}"

  ip_configuration {
    name                          = "${var.chef_computer_name}-ipconf"
    subnet_id                     = "${var.subnet_id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${element(azurerm_public_ip.chef.*.id, count.index)}"
  }
}

# VIRTUAL MACHINE 
resource "azurerm_virtual_machine" "chef" {
  name                  = "${var.chef_computer_name}"
  location              = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.chef.name}"
  network_interface_ids = ["${azurerm_network_interface.chef.id}"]
  vm_size               = "${var.vm_size}"

  storage_image_reference {
    publisher = "${var.publisher}"
    offer     = "${var.offer}"
    sku       = "${var.sku}"
    version   = "${var.version}"
  }

  storage_os_disk {
    name          = "${var.chef_computer_name}-osdisk"
    caching       = "ReadWrite"
    create_option = "FromImage"
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = "100"
    os_type           = "linux"
  }

  os_profile {
    computer_name  = "${var.chef_computer_name}"
    admin_username = "${var.chef_admin_user}"
    admin_password = "${var.chef_admin_password}"
  }
  
  os_profile_linux_config {
    disable_password_authentication = false
      ssh_keys {
        path = "/home/${var.chef_admin_user}/.ssh/authorized_keys"
        key_data = "${file("~/.ssh/id_rsa.pub")}"
    }
  }

  connection {
      type = "ssh"
      host = "${element(azurerm_public_ip.chef.*.ip_address, count.index)}"
      user = "${var.chef_admin_user}"
      # password = "${var.admin_password}"
      private_key = "${file("~/.ssh/id_rsa")}"
      agent = false
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
      "sudo git clone https://scott_flaherty:xxx@bitbucket.org/cb_dvo_chefserver.git /var/chef/cookbooks/cb_dvo_chefserver",
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
# #### AUTOMATE ####
# Create resource group that will be used with automate deploy
resource "azurerm_resource_group" "automate" {
  name     = "${var.auto_resource_group_name}"
  location = "${var.location}"
}

# Create public IPs
resource "azurerm_public_ip" "automate" {
    name                         = "${var.auto_computer_name}-pubip"
    location                     = "${azurerm_resource_group.automate.location}"
    resource_group_name          = "${azurerm_resource_group.automate.name}"
    allocation_method            = "public"
}

# Create virtual NIC that will be used with our automate instance.
resource "azurerm_network_interface" "automate" {
  name                = "${azurerm_resource_group.automate.name}-nic"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.automate.name}"

  ip_configuration {
    name                          = "${var.auto_computer_name}-ipconf"
    subnet_id                     = "${var.subnet_id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${element(azurerm_public_ip.automate.*.id, count.index)}"
  }
}

# VIRTUAL MACHINE 
resource "azurerm_virtual_machine" "automate" {
  name                  = "${var.auto_computer_name}"
  location              = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.automate.name}"
  network_interface_ids = ["${azurerm_network_interface.automate.id}"]
  vm_size               = "${var.vm_size}"

  storage_image_reference {
    publisher = "${var.publisher}"
    offer     = "${var.offer}"
    sku       = "${var.sku}"
    version   = "${var.version}"
  }

  storage_os_disk {
    name          = "${var.auto_computer_name}-osdisk"
    caching       = "ReadWrite"
    create_option = "FromImage"
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = "100"
    os_type           = "linux"
  }

  os_profile {
    computer_name  = "${var.auto_computer_name}"
    admin_username = "${var.auto_admin_user}"
    admin_password = "${var.auto_admin_password}"
  }
  
  os_profile_linux_config {
    disable_password_authentication = false
      ssh_keys {
        path = "/home/${var.auto_admin_user}/.ssh/authorized_keys"
        key_data = "${file("~/.ssh/id_rsa.pub")}"
    }
  }

  connection {
      type = "ssh"
      host = "${element(azurerm_public_ip.automate.*.ip_address, count.index)}"
      user = "${var.auto_admin_user}"
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
  # provisioner "local-exec" {
  #      command = "sudo mkdir -p /drop"
  # }
  # provisioner "local-exec" {
  #      command = "sudo scp ${var.auto_admin_user}@${azurerm_virtual_machine.chef.private_ip}:/drop/delivery.pem /tmp/delivery_user.pem"
  # }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install git -y",
      "sudo curl --connect-timeout 60 -L https://www.chef.io/chef/install.sh | sudo bash",
      "sudo mkdir -p /var/chef/cache /var/chef/cookbooks",
      "sudo git clone https://scott_flaherty:Grad_2155@bitbucket.org/cb_dvo_cautomate.git /var/chef/cookbooks/cb_dvo_cautomate",
      "sudo wget -qO- https://supermarket.chef.io/cookbooks/ohai/versions/5.2.0/download |sudo tar xvzC /var/chef/cookbooks",
      "sudo wget -qO- https://supermarket.chef.io/cookbooks/sysctl/versions/0.10.2/download |sudo tar xvzC /var/chef/cookbooks",
      # "sudo scp $CHEF_USER@$CHEF_SERVER:/drop/delivery.pem /tmp/delivery_user.pem"
      "sudo mv /var/chef/cookbooks/cb_dvo_cautomate/data_bags /var/chef/",
      "sudo mv /tmp/stuff_and_things.json /var/chef/cache/stuff_and_things.json",
      "sudo chef-solo -j '/var/chef/cache/stuff_and_things.json' -o 'recipe[cb_dvo_cautomate::default]'"
    ]
  }
  depends_on = ["azurerm_virtual_machine.chef"]
}

