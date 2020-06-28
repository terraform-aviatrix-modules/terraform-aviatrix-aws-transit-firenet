variable "region" {
  type = string
}

variable "cidr" {
  type = string
}

variable "aws_account_name" {
  type = string
}

variable "instance_size" {
  type    = string
  default = "c5.xlarge"
}

variable "fw_instance_size" {
  type    = string
  default = "c5.xlarge"
}

variable "ha_gw" {
  type    = bool
  default = true
}

variable "attached" {
  type    = bool
  default = true
}

variable "firewall_image" {
  type    = string
}