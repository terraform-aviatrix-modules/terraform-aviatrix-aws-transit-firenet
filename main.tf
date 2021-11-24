#Transit VPC
resource "aviatrix_vpc" "default" {
  cloud_type           = local.cloud_type
  name                 = local.name
  region               = var.region
  cidr                 = var.cidr
  account_name         = var.account
  aviatrix_firenet_vpc = true
  aviatrix_transit_vpc = false
}

#Transit GW
resource "aviatrix_transit_gateway" "default" {
  enable_active_mesh               = var.active_mesh
  cloud_type                       = local.cloud_type
  vpc_reg                          = var.region
  gw_name                          = local.name
  gw_size                          = var.instance_size
  vpc_id                           = aviatrix_vpc.default.vpc_id
  account_name                     = var.account
  subnet                           = local.subnet
  ha_subnet                        = var.ha_gw ? (local.single_az_mode ? local.subnet : local.ha_subnet) : null
  enable_transit_firenet           = true
  ha_gw_size                       = var.ha_gw ? var.instance_size : null
  connected_transit                = var.enable_egress_transit_firenet ? false : var.connected_transit
  enable_hybrid_connection         = var.hybrid_connection
  bgp_manual_spoke_advertise_cidrs = var.bgp_manual_spoke_advertise_cidrs
  enable_learned_cidrs_approval    = var.learned_cidr_approval
  insane_mode                      = var.insane_mode
  insane_mode_az                   = local.insane_mode_az
  ha_insane_mode_az                = var.ha_gw ? local.ha_insane_mode_az : null
  enable_segmentation              = var.enable_segmentation
  single_az_ha                     = var.single_az_ha
  single_ip_snat                   = var.single_ip_snat
  enable_advertise_transit_cidr    = var.enable_advertise_transit_cidr
  bgp_polling_time                 = var.bgp_polling_time
  bgp_ecmp                         = var.bgp_ecmp
  local_as_number                  = var.local_as_number
  enable_egress_transit_firenet    = var.enable_egress_transit_firenet
  enable_bgp_over_lan              = var.enable_bgp_over_lan
  enable_gateway_load_balancer     = var.use_gwlb
  enable_encrypt_volume            = var.enable_encrypt_volume
  customer_managed_keys            = var.customer_managed_keys
  tunnel_detection_time            = var.tunnel_detection_time
  tags                             = var.tags
  enable_multi_tier_transit        = var.enable_multi_tier_transit
  learned_cidrs_approval_mode      = var.learned_cidrs_approval_mode
}

#Firewall instances
resource "aviatrix_firewall_instance" "firewall_instance" {
  count                  = var.ha_gw ? 0 : (local.is_aviatrix ? 0 : 1) #If ha is false, and is_aviatrix is false, deploy 1
  firewall_name          = "${local.name}-fw"
  firewall_size          = var.fw_instance_size
  vpc_id                 = aviatrix_vpc.default.vpc_id
  firewall_image         = var.firewall_image
  firewall_image_version = var.firewall_image_version
  egress_subnet          = aviatrix_vpc.default.subnets[1].cidr
  firenet_gw_name        = aviatrix_transit_gateway.default.gw_name
  iam_role               = var.iam_role_1
  bootstrap_bucket_name  = var.bootstrap_bucket_name_1
  management_subnet      = local.is_palo ? aviatrix_vpc.default.subnets[0].cidr : null
  zone                   = var.use_gwlb ? local.az1 : null
  firewall_image_id      = var.firewall_image_id
  user_data              = var.user_data_1
  tags                   = var.fw_tags
}

resource "aviatrix_firewall_instance" "firewall_instance_1" {
  count                  = var.ha_gw ? (local.is_aviatrix ? 0 : var.fw_amount / 2) : 0 #If ha is true, and is_aviatrix is false, deploy var.fw_amount / 2
  firewall_name          = "${local.name}-az1-fw${count.index + 1}"
  firewall_size          = var.fw_instance_size
  vpc_id                 = aviatrix_vpc.default.vpc_id
  firewall_image         = var.firewall_image
  firewall_image_version = var.firewall_image_version
  egress_subnet          = aviatrix_vpc.default.subnets[1].cidr
  firenet_gw_name        = aviatrix_transit_gateway.default.gw_name
  iam_role               = var.iam_role_1
  bootstrap_bucket_name  = var.bootstrap_bucket_name_1
  management_subnet      = local.is_palo ? aviatrix_vpc.default.subnets[0].cidr : null
  zone                   = var.use_gwlb ? local.az1 : null
  firewall_image_id      = var.firewall_image_id
  user_data              = var.user_data_1
  tags                   = var.fw_tags
}

resource "aviatrix_firewall_instance" "firewall_instance_2" {
  count                  = var.ha_gw ? (local.is_aviatrix ? 0 : var.fw_amount / 2) : 0 #If ha is true, and is_aviatrix is false, deploy var.fw_amount / 2
  firewall_name          = "${local.name}-az2-fw${count.index + 1}"
  firewall_size          = var.fw_instance_size
  vpc_id                 = aviatrix_vpc.default.vpc_id
  firewall_image         = var.firewall_image
  firewall_image_version = var.firewall_image_version
  egress_subnet          = local.single_az_mode ? aviatrix_vpc.default.subnets[1].cidr : aviatrix_vpc.default.subnets[3].cidr
  firenet_gw_name        = aviatrix_transit_gateway.default.ha_gw_name
  iam_role               = local.iam_role_2
  bootstrap_bucket_name  = local.bootstrap_bucket_name_2
  management_subnet      = local.is_palo ? (local.single_az_mode ? aviatrix_vpc.default.subnets[0].cidr : aviatrix_vpc.default.subnets[2].cidr) : null
  zone                   = var.use_gwlb ? local.az2 : null
  firewall_image_id      = var.firewall_image_id
  user_data              = local.user_data_2
  tags                   = var.fw_tags
}

#FQDN Egress filtering instances
resource "aviatrix_gateway" "egress_instance" {
  count        = var.ha_gw ? 0 : (local.is_aviatrix ? 1 : 0) #If ha is false, and is_aviatrix is true, deploy 1
  cloud_type   = 1
  account_name = var.account
  gw_name      = "${local.name}-egress-gw"
  vpc_id       = aviatrix_vpc.default.vpc_id
  vpc_reg      = var.region
  gw_size      = var.fw_instance_size
  subnet       = aviatrix_vpc.default.subnets[1].cidr
  single_az_ha = var.single_az_ha
  tags         = var.fw_tags
}

resource "aviatrix_gateway" "egress_instance_1" {
  count        = var.ha_gw ? (local.is_aviatrix ? var.fw_amount / 2 : 0) : 0 #If ha is true, and is_aviatrix is true, deploy var.fw_amount / 2
  cloud_type   = 1
  account_name = var.account
  gw_name      = "${local.name}-az1-egress-gw${count.index + 1}"
  vpc_id       = aviatrix_vpc.default.vpc_id
  vpc_reg      = var.region
  gw_size      = var.fw_instance_size
  subnet       = aviatrix_vpc.default.subnets[1].cidr
  single_az_ha = var.single_az_ha
  tags         = var.fw_tags
}

resource "aviatrix_gateway" "egress_instance_2" {
  count        = var.ha_gw ? (local.is_aviatrix ? var.fw_amount / 2 : 0) : 0 #If ha is true, and is_aviatrix is true, deploy var.fw_amount / 2
  cloud_type   = 1
  account_name = var.account
  gw_name      = "${local.name}-az2-egress-gw${count.index + 1}"
  vpc_id       = aviatrix_vpc.default.vpc_id
  vpc_reg      = var.region
  gw_size      = var.fw_instance_size
  subnet       = local.single_az_mode ? aviatrix_vpc.default.subnets[1].cidr : aviatrix_vpc.default.subnets[3].cidr
  single_az_ha = var.single_az_ha
  tags         = var.fw_tags
}

#Firenet
resource "aviatrix_firenet" "firenet" {
  vpc_id                               = aviatrix_vpc.default.vpc_id
  inspection_enabled                   = local.is_aviatrix || var.enable_egress_transit_firenet ? false : var.inspection_enabled #Always switch to false if Aviatrix FQDN egress or egress transit firenet.
  egress_enabled                       = local.is_aviatrix || var.enable_egress_transit_firenet ? true : var.egress_enabled      #Always switch to true if Aviatrix FQDN egress or egress transit firenet.
  keep_alive_via_lan_interface_enabled = var.keep_alive_via_lan_interface_enabled
  manage_firewall_instance_association = false
  egress_static_cidrs                  = var.egress_static_cidrs
  fail_close_enabled                   = var.fail_close_enabled
  east_west_inspection_excluded_cidrs  = var.east_west_inspection_excluded_cidrs

  depends_on = [
    aviatrix_firewall_instance_association.firenet_instance1,
    aviatrix_firewall_instance_association.firenet_instance2,
    aviatrix_firewall_instance_association.firenet_instance,
    aviatrix_gateway.egress_instance,
    aviatrix_gateway.egress_instance_1,
    aviatrix_gateway.egress_instance_2,
    aviatrix_transit_gateway.default,
  ]
}

resource "aviatrix_firewall_instance_association" "firenet_instance" {
  count                = var.ha_gw ? 0 : 1
  vpc_id               = aviatrix_vpc.default.vpc_id
  firenet_gw_name      = aviatrix_transit_gateway.default.gw_name
  instance_id          = local.is_aviatrix ? aviatrix_gateway.egress_instance[0].gw_name : aviatrix_firewall_instance.firewall_instance[0].instance_id
  firewall_name        = local.is_aviatrix ? null : aviatrix_firewall_instance.firewall_instance[0].firewall_name
  lan_interface        = local.is_aviatrix ? null : aviatrix_firewall_instance.firewall_instance[0].lan_interface
  management_interface = local.is_aviatrix ? null : aviatrix_firewall_instance.firewall_instance[0].management_interface
  egress_interface     = local.is_aviatrix ? null : aviatrix_firewall_instance.firewall_instance[0].egress_interface
  vendor_type          = local.is_aviatrix ? "fqdn_gateway" : null
  attached             = var.attached
}

resource "aviatrix_firewall_instance_association" "firenet_instance1" {
  count                = var.ha_gw ? var.fw_amount / 2 : 0
  vpc_id               = aviatrix_vpc.default.vpc_id
  firenet_gw_name      = aviatrix_transit_gateway.default.gw_name
  instance_id          = local.is_aviatrix ? aviatrix_gateway.egress_instance_1[count.index].gw_name : aviatrix_firewall_instance.firewall_instance_1[count.index].instance_id
  firewall_name        = local.is_aviatrix ? null : aviatrix_firewall_instance.firewall_instance_1[count.index].firewall_name
  lan_interface        = local.is_aviatrix ? null : aviatrix_firewall_instance.firewall_instance_1[count.index].lan_interface
  management_interface = local.is_aviatrix ? null : aviatrix_firewall_instance.firewall_instance_1[count.index].management_interface
  egress_interface     = local.is_aviatrix ? null : aviatrix_firewall_instance.firewall_instance_1[count.index].egress_interface
  vendor_type          = local.is_aviatrix ? "fqdn_gateway" : null
  attached             = var.attached
}

resource "aviatrix_firewall_instance_association" "firenet_instance2" {
  count                = var.ha_gw ? var.fw_amount / 2 : 0
  vpc_id               = aviatrix_vpc.default.vpc_id
  firenet_gw_name      = aviatrix_transit_gateway.default.ha_gw_name
  instance_id          = local.is_aviatrix ? aviatrix_gateway.egress_instance_2[count.index].gw_name : aviatrix_firewall_instance.firewall_instance_2[count.index].instance_id
  firewall_name        = local.is_aviatrix ? null : aviatrix_firewall_instance.firewall_instance_2[count.index].firewall_name
  lan_interface        = local.is_aviatrix ? null : aviatrix_firewall_instance.firewall_instance_2[count.index].lan_interface
  management_interface = local.is_aviatrix ? null : aviatrix_firewall_instance.firewall_instance_2[count.index].management_interface
  egress_interface     = local.is_aviatrix ? null : aviatrix_firewall_instance.firewall_instance_2[count.index].egress_interface
  vendor_type          = local.is_aviatrix ? "fqdn_gateway" : null
  attached             = var.attached
}
