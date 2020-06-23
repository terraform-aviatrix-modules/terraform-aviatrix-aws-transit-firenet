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
    type = string
    default = "t2.micro"
}

variable "ha_gw" {
    type = bool
    default = false
}

variable "attached" {
    type = bool
    default = true
}