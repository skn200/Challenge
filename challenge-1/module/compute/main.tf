locals {
  instance = flatten([
    for value in var.instance: {
      name         = value.name
      size         = value.size
    }
  ])
  instance_map = {
    for value in local.instance: "${value.name}" => value
  }

  #avset_id = var.avset_id != "" ? var.avset_id : null
  
}

locals {
  os_disk = {
    name        = var.os_disk.name
    size        = var.os_disk.size
    caching     = var.os_disk.caching
    sku         = var.os_disk.sku
  }
  data_disk = flatten([
    for value in var.data_disk: {
      name        = value.name
      lun         = value.lun
      size        = value.size
      caching     = value.caching
      sku         = value.sku
    }
  ])
  data_disk_map = {
    for value in local.data_disk: "${value.name}" => value
  }
}

resource "azurerm_availability_set" "avset" {
  name                = var.avset.name
  location            = var.location
  resource_group_name = var.resource_group_name

  managed                      = var.avset.managed
  platform_update_domain_count = var.avset.ud_count
  platform_fault_domain_count  = var.avset.fd_count

  tags = var.tags
}

resource "azurerm_network_interface" "nic" {
  for_each = local.instance_map

  name                             = "${each.value.name}-nic-1"
  location                         = var.location
  resource_group_name              = var.resource_group_name

  ip_configuration {
    name                           = "ipconfig-1"
    subnet_id                      = var.nic.subnet_id
    primary                        = true
    private_ip_address_allocation  = "Dynamic"

  }

  tags = var.tags
}

resource "azurerm_virtual_machine" "vm" {
  for_each = local.instance_map

  name                         = each.value.name
  location                     = var.location
  resource_group_name          = var.resource_group_name
  vm_size                      = each.value.size

  network_interface_ids        = [azurerm_network_interface.nic[each.key].id]
  primary_network_interface_id = azurerm_network_interface.nic[each.key].id

  availability_set_id          = azurerm_availability_set.avset.id
    

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    id                             = var.os_image.id
    publisher                      = var.os_image.publisher
    offer                          = var.os_image.offer
    sku                            = var.os_image.sku
    version                        = var.os_image.version
  }

  storage_os_disk {
    name                      = "${each.value.name}-${local.os_disk.name}"
    create_option             = "FromImage"
    os_type                   = "Linux"
    disk_size_gb              = local.os_disk.size
    caching                   = local.os_disk.caching
    managed_disk_type         = local.os_disk.sku
  }

  dynamic "storage_data_disk" {
    for_each = local.data_disk_map
    iterator = object

    content {
      name                      = "${each.value.name}-${object.value.name}"
      create_option             = "Empty"
      lun                       = object.value.lun
      disk_size_gb              = object.value.size
      caching                   = object.value.caching
      managed_disk_type         = object.value.sku
      
    }
  }

  os_profile {
    computer_name              = each.value.name
    admin_username             = var.root.user_name
    custom_data                = var.custom_data
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      key_data                      = var.root.ssh_key
      path                          = "/home/${var.root.user_name}/.ssh/authorized_keys"
    }
  }

  
  
  tags = var.tags
}