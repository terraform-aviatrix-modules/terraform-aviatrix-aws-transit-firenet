#Transit VPC
resource "aviatrix_vpc" "default" {
  cloud_type           = 1
  name                 = "firenet-${var.region}"
  region               = var.region
  cidr                 = var.cidr
  account_name         = var.aws_account_name
  aviatrix_firenet_vpc = true
  aviatrix_transit_vpc = false
}

# Single Transit GW
resource "aviatrix_transit_gateway" "single" {
  count                  = var.ha_gw ? 0 : 1
  enable_active_mesh     = true
  cloud_type             = 1
  vpc_reg                = var.region
  gw_name                = "tg-${var.region}"
  gw_size                = var.instance_size
  vpc_id                 = aviatrix_vpc.default.vpc_id
  account_name           = var.aws_account_name
  subnet                 = aviatrix_vpc.default.subnets[0].cidr
  enable_transit_firenet = true
  connected_transit      = true
}

# HA Transit GW
resource "aviatrix_transit_gateway" "ha" {
  count                  = var.ha_gw ? 1 : 0
  enable_active_mesh     = true
  cloud_type             = 1
  vpc_reg                = var.region
  gw_name                = "tg-${var.region}"
  gw_size                = var.instance_size
  vpc_id                 = aviatrix_vpc.default.vpc_id
  account_name           = var.aws_account_name
  subnet                 = aviatrix_vpc.default.subnets[0].cidr
  ha_subnet              = aviatrix_vpc.default.subnets[2].cidr
  enable_transit_firenet = true
  ha_gw_size             = var.instance_size
  connected_transit      = true
}

#Firewall instances
resource "aviatrix_firewall_instance" "firewall_instance" {
  count                 = var.ha_gw ? 0 : 1
  firewall_name         = "fw1-${var.region}"
  firewall_size         = var.fw_instance_size
  vpc_id                = aviatrix_vpc.default.vpc_id
  firewall_image        = var.firewall_image
  egress_subnet         = aviatrix_vpc.default.subnets[1].cidr
  firenet_gw_name       = aviatrix_transit_gateway.single[0].gw_name
  iam_role              = null
  bootstrap_bucket_name = null
  management_subnet     = aviatrix_vpc.default.subnets[1].cidr
}

resource "aviatrix_firewall_instance" "firewall_instance_1" {
  count                 = var.ha_gw ? var.fw_amount / 2 : 0
  firewall_name         = "fw-az1-${count.index+1}-${var.region}"
  firewall_size         = var.fw_instance_size
  vpc_id                = aviatrix_vpc.default.vpc_id
  firewall_image        = var.firewall_image
  egress_subnet         = aviatrix_vpc.default.subnets[1].cidr
  firenet_gw_name       = aviatrix_transit_gateway.ha[0].gw_name
  iam_role              = null
  bootstrap_bucket_name = null
  management_subnet     = aviatrix_vpc.default.subnets[1].cidr
}

resource "aviatrix_firewall_instance" "firewall_instance_2" {
  count                 = var.ha_gw ? var.fw_amount / 2 : 0
  firewall_name         = "fw-az2-${count.index+1}-${var.region}"
  firewall_size         = var.fw_instance_size
  vpc_id                = aviatrix_vpc.default.vpc_id
  firewall_image        = var.firewall_image
  egress_subnet         = aviatrix_vpc.default.subnets[3].cidr
  firenet_gw_name       = "${aviatrix_transit_gateway.ha[0].gw_name}-hagw"
  iam_role              = null
  bootstrap_bucket_name = null
  management_subnet     = aviatrix_vpc.default.subnets[3].cidr
}

#Firenet
resource "aviatrix_firenet" "firenet" {
  count              = var.ha_gw ? 0 : 1
  vpc_id             = aviatrix_vpc.default.vpc_id
  inspection_enabled = true
  egress_enabled     = true


firewall_instance_association {
    firenet_gw_name      = aviatrix_transit_gateway.single[0].gw_name
    instance_id          = aviatrix_firewall_instance.firewall_instance[0].instance_id
    vendor_type          = "Generic"
    firewall_name        = aviatrix_firewall_instance.firewall_instance[0].firewall_name
    lan_interface        = aviatrix_firewall_instance.firewall_instance[0].lan_interface
    management_interface = null
    egress_interface     = aviatrix_firewall_instance.firewall_instance[0].egress_interface
    attached             = var.attached
  }
}

resource "aviatrix_firenet" "firenet_ha" {
  count              = var.ha_gw ? 1 : 0
  vpc_id             = aviatrix_vpc.default.vpc_id
  inspection_enabled = true
  egress_enabled     = true

  dynamic firewall_instance_association {
    for_each = aviatrix_firewall_instance.firewall_instance_1

    content {
      firenet_gw_name      = aviatrix_transit_gateway.ha[0].gw_name
      instance_id          = firewall_instance_association.value.instance_id
      vendor_type          = "Generic"
      firewall_name        = firewall_instance_association.value.firewall_name
      lan_interface        = firewall_instance_association.value.lan_interface
      management_interface = null
      egress_interface     = firewall_instance_association.value.egress_interface
      attached             = var.attached
    }
  }
  dynamic firewall_instance_association {
    for_each = aviatrix_firewall_instance.firewall_instance_2
  
    content {
      firenet_gw_name      = "${aviatrix_transit_gateway.ha[0].gw_name}-hagw"
      instance_id          = firewall_instance_association.value.instance_id
      vendor_type          = "Generic"
      firewall_name        = firewall_instance_association.value.firewall_name
      lan_interface        = firewall_instance_association.value.lan_interface
      management_interface = null
      egress_interface     = firewall_instance_association.value.egress_interface
      attached             = var.attached
    }
  }
}