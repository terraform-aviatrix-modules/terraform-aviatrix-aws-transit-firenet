variable "region" {
  description = "The AWS region to deploy this module in"
  type        = string
}

variable "cidr" {
  description = "The CIDR range to be used for the VPC"
  type        = string
}

variable "account" {
  description = "The AWS account name, as known by the Aviatrix controller"
  type        = string
}

variable "name" {
  description = "Optionally provide a custom name for VPC and Gateway resources."
  type        = string
  default     = ""
}

variable "prefix" {
  description = "Boolean to determine if name will be prepended with avx-"
  type        = bool
  default     = true
}

variable "suffix" {
  description = "Boolean to determine if name will be appended with -spoke"
  type        = bool
  default     = true
}

variable "instance_size" {
  description = "AWS Instance size for the Aviatrix gateways"
  type        = string
  default     = "c5.xlarge"
}

variable "fw_instance_size" {
  description = "AWS Instance size for the NGFW's"
  type        = string
  default     = "c5.xlarge"
}

variable "ha_gw" {
  description = "Boolean to determine if module will be deployed in HA or single mode"
  type        = bool
  default     = true
}

variable "fw_amount" {
  description = "Integer that determines the amount of NGFW instances to launch"
  type        = number
  default     = 2
}

variable "attached" {
  description = "Boolean to determine if the spawned firewall instances will be attached on creation"
  type        = bool
  default     = true
}

variable "firewall_image" {
  description = "The firewall image to be used to deploy the NGFW's"
  type        = string
}

variable "firewall_image_version" {
  description = "The software version to be used to deploy the NGFW's"
  type        = string
  default     = null
}

variable "iam_role" {
  description = "The IAM role for bootstrapping"
  type        = string
  default     = null
}

variable "bootstrap_bucket_name" {
  description = "The firewall bootstrap bucket name"
  type        = string
  default     = null
}

variable "inspection_enabled" {
  description = "Set to false to disable inspection"
  type        = bool
  default     = true
}

variable "egress_enabled" {
  description = "Set to true to enable egress on FW instances"
  type        = bool
  default     = false
}

variable "enable_egress_transit_firenet" {
  description = "Set to true to enable egress on transit gw"
  type        = bool
  default     = false
}

variable "keep_alive_via_lan_interface_enabled" {
  description = "Enable Keep Alive via Firewall LAN Interface"
  type        = bool
  default     = false
}

variable "local_as_number" {
  description = "Changes the Aviatrix Transit Gateway ASN number before you setup Aviatrix Transit Gateway connection configurations."
  type        = number
  default     = null
}

variable "insane_mode" {
  description = "Set to true to enable Aviatrix high performance encryption."
  type        = bool
  default     = false
}

variable "az1" {
  description = "Concatenates with region to form az names. e.g. eu-central-1a. Only used for insane mode"
  type        = string
  default     = "a"
}

variable "az2" {
  description = "Concatenates with region to form az names. e.g. eu-central-1b. Only used for insane mode"
  type        = string
  default     = "b"
}

variable "connected_transit" {
  description = "Set to false to disable connected transit."
  type        = bool
  default     = true
}

variable "hybrid_connection" {
  description = "Set to true to prepare Aviatrix transit for TGW connection."
  type        = bool
  default     = false
}

variable "bgp_manual_spoke_advertise_cidrs" {
  description = "Define a list of CIDRs that should be advertised via BGP."
  type        = string
  default     = ""
}

variable "learned_cidr_approval" {
  description = "Set to true to enable learned CIDR approval."
  type        = string
  default     = "false"
}

variable "active_mesh" {
  description = "Set to false to disable active mesh."
  type        = bool
  default     = true
}

variable "enable_segmentation" {
  description = "Switch to true to enable transit segmentation"
  type        = bool
  default     = false
}

variable "single_az_ha" {
  description = "Set to true if Controller managed Gateway HA is desired"
  type        = bool
  default     = true
}

variable "single_ip_snat" {
  description = "Enable single_ip mode Source NAT for this container"
  type        = bool
  default     = false
}

variable "enable_advertise_transit_cidr" {
  description = "Switch to enable/disable advertise transit VPC network CIDR for a VGW connection"
  type        = bool
  default     = false
}

variable "bgp_polling_time" {
  description = "BGP route polling time. Unit is in seconds"
  type        = string
  default     = "50"
}

variable "bgp_ecmp" {
  description = "Enable Equal Cost Multi Path (ECMP) routing for the next hop"
  type        = bool
  default     = false
}

variable "enable_bgp_over_lan" {
  description = "Enable BGP over LAN. Creates eth4 for integration with SDWAN for example"
  type        = bool
  default     = false
}

variable "enable_native_gwlb" {
  description = "Enable GWLB for NGFW integration"
  type        = bool
  default     = false
}

locals {
  lower_name        = length(var.name) > 0 ? replace(lower(var.name), " ", "-") : replace(lower(var.region), " ", "-")
  prefix            = var.prefix ? "avx-" : ""
  suffix            = var.suffix ? "-firenet" : ""
  is_palo           = length(regexall("palo", lower(var.firewall_image))) > 0 #Check if fw image is palo. Needs special handling for management_subnet (CP & Fortigate null)
  name              = "${local.prefix}${local.lower_name}${local.suffix}"
  subnet            = var.insane_mode ? cidrsubnet(var.cidr, local.newbits, local.netnum - 2) : aviatrix_vpc.default.public_subnets[2].cidr
  ha_subnet         = var.insane_mode ? cidrsubnet(var.cidr, local.newbits, local.netnum - 1) : aviatrix_vpc.default.public_subnets[3].cidr
  az1               = "${var.region}${var.az1}"
  az2               = "${var.region}${var.az2}"
  insane_mode_az    = var.insane_mode ? local.az1 : null
  ha_insane_mode_az = var.insane_mode ? local.az2 : null
}
