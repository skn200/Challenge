locals {
  data_disk = flatten([
    for value in var.data_disk : {
      lun     = value.lun
      size    = value.size
      caching = value.caching != "" ? value.caching : "None"
      sku     = value.sku != "" ? value.sku : "Standard_LRS"
    }
  ])
  data_disk_map = {
    for value in local.data_disk : "disk-data-${value.lun}" => value
  }
}

resource "azurerm_virtual_machine_scale_set" "vmss" {
  name                = var.scale_set.name
  location            = var.location
  resource_group_name = var.resource_group_name


  priority             = var.scale_set.priority != "" ? var.scale_set.priority : "Regular"
  upgrade_policy_mode  = var.policy.upgrade
  automatic_os_upgrade = var.policy.os != "" ? var.policy.os : false
  eviction_policy      = var.policy.eviction != "" ? var.policy.eviction : null
  overprovision        = var.policy.overprovision != "" ? var.policy.overprovision : true

  single_placement_group       = var.single_placement_group != "" ? var.single_placement_group : true
  proximity_placement_group_id = var.scale_set.ppg_id != "" ? var.scale_set.ppg_id : null

  health_probe_id = var.scale_set.probe_id != "" ? var.scale_set.probe_id : null
  zones           = length(var.scale_set.avzone) > 0 ? var.scale_set.avzone : null

  sku {
    name     = var.sku.size
    tier     = var.sku.tier != "" ? var.sku.tier : "Standard"
    capacity = var.sku.capacity
  }

  os_profile {
    computer_name_prefix = var.scale_set.name
    admin_username       = var.root.user_name != "" ? var.root.user_name : "adminuser"
    admin_password       = var.root.password
  }

  os_profile_linux_config {
    disable_password_authentication = true

  }

  dynamic "identity" {
    for_each = length(var.identity.user_id_ids) > 0 ? { "UserAssigned" = var.identity.user_id_ids } : {}
    iterator = object

    content {
      type         = object.key
      identity_ids = object.value
    }
  }

  dynamic "identity" {
    for_each = var.identity.system == true ? ["SystemAssigned"] : []
    iterator = object

    content {
      type = object.value
    }
  }

  network_profile {
    name    = "${var.scale_set.name}-nic-1"
    primary = true

    accelerated_networking = var.nic.accelerated != "" ? var.nic.accelerated : false
    ip_forwarding          = var.nic.ipforward != "" ? var.nic.ipforward : false
    #network_security_group_id = var.nic.nsg_id != "" ? var.nic.nsg_id : null


    ip_configuration {
      name      = "ipconfig-1"
      primary   = true
      subnet_id = var.nic.subnet_id

      application_gateway_backend_address_pool_ids = length(var.nic.appgw_pool_ids) > 0 ? var.nic.appgw_pool_ids : null
      load_balancer_backend_address_pool_ids       = length(var.nic.lb_pool_ids) > 0 ? var.nic.lb_pool_ids : null
    }
  }

  storage_profile_image_reference {
    id        = var.os_image.id != "" ? var.os_image.id : null
    publisher = var.os_image.publisher
    offer     = var.os_image.offer
    sku       = var.os_image.sku
    version   = var.os_image.version != "" ? var.os_image.version : "latest"
  }

  storage_profile_os_disk {
    os_type           = "Linux"
    create_option     = "FromImage"
    caching           = var.os_disk.caching != "" ? var.os_disk.caching : "None"
    managed_disk_type = var.os_disk.sku != "" ? var.os_disk.sku : "Standard_LRS"
  }

  dynamic "storage_profile_data_disk" {
    for_each = local.data_disk_map
    iterator = object

    content {
      create_option     = "Empty"
      lun               = object.value.lun
      disk_size_gb      = object.value.size
      caching           = object.value.caching
      managed_disk_type = object.value.sku
    }
  }

  tags = var.tags
}