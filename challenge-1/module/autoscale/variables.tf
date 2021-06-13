variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "name" {
  type = string
}

variable "target_id" {
  type = string
}

variable "enabled" {
  type = bool
}


variable "profile" {
  type = list(object({
    name = string
    capacity = object({
      default = number
      min     = number
      max     = number
    })
    rule = list(object({
      name = string
      trigger = object({
        name             = string
        target_id        = string
        operator         = string
        statistic        = string
        time_aggregation = string
        time_grain       = string
        time_window      = string
        threshold        = string
      })
      action = object({
        cooldown  = string
        direction = string
        type      = string
        value     = string
      })
    }))
  }))
}

variable "notification" {
  type = object({
    name            = string
    send_to_admin   = bool
    send_to_coadmin = bool
    custom_emails   = list(string)
  })
}

variable "tags" {
  default = {}
  type    = map(string)
}

