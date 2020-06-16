#Transit VPC
resource "aviatrix_vpc" "default" {
  cloud_type           = 1
  name                 = "vpc-transit-${var.region}"
  region               = var.region
  cidr                 = var.cidr
  account_name         = var.aws_account_name
  aviatrix_firenet_vpc = false
  aviatrix_transit_vpc = true
}

# Single Transit GW
resource "aviatrix_transit_gateway" "single" {
  count = var.ha_gw ? 0 : 1
  enable_active_mesh = true
  cloud_type         = 1
  vpc_reg            = var.region
  gw_name            = "tg-${var.region}"
  gw_size            = var.instance_size
  vpc_id             = aviatrix_vpc.default.vpc_id
  account_name       = var.aws_account_name
  subnet             = aviatrix_vpc.default.subnets[4].cidr
  connected_transit  = true
  tag_list = [
    "Auto-StartStop-Enabled:",
  ]
}

# HA Transit GW
resource "aviatrix_transit_gateway" "ha" {
  count = var.ha_gw ? 1 : 0
  enable_active_mesh = true
  cloud_type         = 1
  vpc_reg            = var.region
  gw_name            = "tg-${var.region}"
  gw_size            = var.instance_size
  vpc_id             = aviatrix_vpc.default.vpc_id
  account_name       = var.aws_account_name
  subnet             = aviatrix_vpc.default.subnets[4].cidr
  ha_subnet          = aviatrix_vpc.default.subnets[6].cidr
  ha_gw_size         = var.instance_size
  connected_transit  = true
  tag_list = [
    "Auto-StartStop-Enabled:",
  ]
}

