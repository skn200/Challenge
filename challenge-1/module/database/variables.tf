variable "master_database" {
	type = object({
	  name      = string
	  version   = string
	  admin     = string
	  password  = string
	})
}

variable "resource_group" {
	type = object({
	   name     = string
	   location = string
	})
}

