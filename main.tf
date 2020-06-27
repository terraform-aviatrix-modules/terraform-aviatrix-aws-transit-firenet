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
  count = var.ha_gw ? 0 : 1
  enable_active_mesh = true
  cloud_type         = 1
  vpc_reg            = var.region
  gw_name            = "tg-${var.region}"
  gw_size            = var.instance_size
  vpc_id             = aviatrix_vpc.default.vpc_id
  account_name       = var.aws_account_name
  subnet             = aviatrix_vpc.default.subnets[0].cidr
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
  subnet             = aviatrix_vpc.default.subnets[0].cidr
  ha_subnet          = aviatrix_vpc.default.subnets[2].cidr
  ha_gw_size         = var.instance_size
  connected_transit  = true
  tag_list = [
    "Auto-StartStop-Enabled:",
  ]
}

resource "aviatrix_firewall_instance" "firewall_instance" {
  count = var.ha_gw ? 0 : 1
  firewall_name = "fw1-${var.region}"
  firewall_size = var.fw_instance_size
  vpc_id = aviatrix_vpc.default.vpc_id
  firewall_image = var.firewall_image
  egress_subnet = aviatrix_vpc.default.subnets[1].cidr
  firenet_gw_name = aviatrix_transit_gateway.single.gw_name
  iam_role = null
  bootstrap_bucket_name = null
  management_subnet = aviatrix_vpc.default.subnets[1].cidr
}

resource "aviatrix_firewall_instance" "firewall_instance_1" {
  count = var.ha_gw ? 1 : 0
  firewall_name = "fw1-${var.region}"
  firewall_size = var.fw_instance_size
  vpc_id = aviatrix_vpc.default.vpc_id
  firewall_image = var.firewall_image
  egress_subnet = aviatrix_vpc.default.subnets[1].cidr
  firenet_gw_name = aviatrix_transit_gateway.single.gw_name
  iam_role = null
  bootstrap_bucket_name = null
  management_subnet = aviatrix_vpc.default.subnets[1].cidr
}

resource "aviatrix_firewall_instance" "firewall_instance_2" {
  count = var.ha_gw ? 1 : 0
  firewall_name = "fw2-${var.region}"
  firewall_size = var.fw_instance_size
  vpc_id = aviatrix_vpc.default.vpc_id
  firewall_image = var.firewall_image
  egress_subnet = aviatrix_vpc.default.subnets[3].cidr
  firenet_gw_name = aviatrix_transit_gateway.single.gw_name
  iam_role = null
  bootstrap_bucket_name = null
  management_subnet = aviatrix_vpc.default.subnets[3].cidr
}


resource "aviatrix_firenet" "firenet" {
  count = var.ha_gw ? 0 : 1
    vpc_id = aviatrix_vpc.default.vpc_id
    inspection_enabled = true
    egress_enabled = true
    firewall_instance_association {
        firenet_gw_name = aviatrix_transit_gateway.single.gw_name
        instance_id = aviatrix_firewall_instance.firewall_instance.instance_id
        vendor_type = "Generic"
        firewall_name = aviatrix_firewall_instance.firewall_instance.firewall_name
        lan_interface = aviatrix_firewall_instance.firewall_instance.lan_interface
        management_interface = null
        egress_interface = aviatrix_firewall_instance.firewall_instance.egress_interface
        attached = var.attached
    }
}

resource "aviatrix_firenet" "firenet_ha" {
  count = var.ha_gw ? 1 : 0
    vpc_id = aviatrix_vpc.default.vpc_id
    inspection_enabled = true
    egress_enabled = true
    firewall_instance_association {
        firenet_gw_name = aviatrix_transit_gateway.single.gw_name
        instance_id = aviatrix_firewall_instance.firewall_instance1.instance_id
        vendor_type = "Generic"
        firewall_name = aviatrix_firewall_instance.firewall_instance1.firewall_name
        lan_interface = aviatrix_firewall_instance.firewall_instance1.lan_interface
        management_interface = null
        egress_interface = aviatrix_firewall_instance.firewall_instance1.egress_interface
        attached = var.attached
    }
    firewall_instance_association {
        firenet_gw_name = aviatrix_transit_gateway.single.gw_name
        instance_id = aviatrix_firewall_instance.firewall_instance2.instance_id
        vendor_type = "Generic"
        firewall_name = aviatrix_firewall_instance.firewall_instance2.firewall_name
        lan_interface = aviatrix_firewall_instance.firewall_instance2.lan_interface
        management_interface = null
        egress_interface = aviatrix_firewall_instance.firewall_instance2.egress_interface
        attached = var.attached
    }
}