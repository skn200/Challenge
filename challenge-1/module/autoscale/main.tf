locals {}

resource "azurerm_monitor_autoscale_setting" "scale" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  target_resource_id  = var.target_id
  enabled             = var.enabled

  dynamic "profile" {
    for_each = {
      for value in var.profile : "${value.name}" => value
    }
    iterator = object

    content {
      name = object.value.name

      capacity {
        default = object.value.capacity.default
        minimum = object.value.capacity.min
        maximum = object.value.capacity.max
      }

      dynamic "rule" {
        for_each = {
          for value in object.value.rule : "${value.name}" => value
        }
        iterator = object_inner

        content {
          metric_trigger {
            metric_name        = object_inner.value.trigger.name
            metric_resource_id = object_inner.value.trigger.target_id
            operator           = object_inner.value.trigger.operator
            statistic          = object_inner.value.trigger.statistic
            time_aggregation   = object_inner.value.trigger.time_aggregation
            time_grain         = object_inner.value.trigger.time_grain
            time_window        = object_inner.value.trigger.time_window
            threshold          = object_inner.value.trigger.threshold
          }

          scale_action {
            cooldown  = object_inner.value.action.cooldown
            direction = object_inner.value.action.direction
            type      = object_inner.value.action.type
            value     = object_inner.value.action.value
          }
        }
      }

    }
  }

  dynamic "notification" {
    for_each = length(var.notification) > 0 ? { "${var.notification.name}" = var.notification } : {}
    iterator = object

    content {
      email {
        send_to_subscription_administrator    = object.value.send_to_admin
        send_to_subscription_co_administrator = object.value.send_to_coadmin
        custom_emails                         = object.value.custom_emails
      }

    }
  }

  tags = var.tags
}