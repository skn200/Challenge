
variable "resource_group" {
	type = string
}

variable "location" {
	type = string
}

variable "web_nsg" {
	type = string
}

variable "app_nsg" {
	type = string
}

variable "db_nsg" {
	type = string
}

variable "app_subnet_id" {
	type = string
}

variable "web_subnet_id" {
	type = string
}

variable "db_subnet_id" {
	type = string
}