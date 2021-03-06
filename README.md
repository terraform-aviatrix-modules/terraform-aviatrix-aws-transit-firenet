# Aviatrix Transit Firenet VPC for AWS

### Description
This module deploys a VPC, Aviatrix transit gateways and firewall instances.

### Compatibility
Module version | Terraform version | Controller version | Terraform provider version
:--- | :--- | :--- | :---
v4.0.x | 0.13 + 0.14 | >=6.4 | >=0.2.19
v3.0.5 | 0.13 | >=6.3 | >=0.2.18
v3.0.4 | 0.13 | >=6.3 | >=0.2.18
v3.0.3 | 0.13 | >=6.3 | >=0.2.18
v3.0.2 | 0.13 | >=6.3 | >=0.2.18
v3.0.1 | 0.13 | >=6.3 | >=0.2.18
v3.0.0 | 0.13 | >=6.2 | >=0.2.17.2

**_Information on older releases can be found in respective release notes._*

### Diagram
<img src="https://github.com/terraform-aviatrix-modules/terraform-aviatrix-aws-transit-firenet/blob/master/img/module-transit-firenet-ha.png?raw=true">

with ha_gw set to false, the following will be deployed:

<img src="https://github.com/terraform-aviatrix-modules/terraform-aviatrix-aws-transit-firenet/blob/master/img/module-transit-firenet.png?raw=true">

### Usage Example
```
module "transit_firenet_1" {
  source  = "terraform-aviatrix-modules/aws-transit-firenet/aviatrix"
  version = "4.0.2"
  
  cidr = "10.1.0.0/20"
  region = "eu-west-1"
  account = "AWS"
  firewall_image = "Fortinet FortiGate (BYOL) Next-Generation Firewall"
}
```

### Variables
The following variables are required:

key | value
--- | ---
region | AWS region to deploy the transit VPC in
account | The AWS accountname on the Aviatrix controller, under which the controller will deploy this VPC
cidr | The IP CIDR wo be used to create the VPC.
firewall_image | String for the firewall image to use

Firewall images
```
Palo Alto Networks VM-Series Next-Generation Firewall Bundle 1
Palo Alto Networks VM-Series Next-Generation Firewall Bundle 1 [VM-300]
Palo Alto Networks VM-Series Next-Generation Firewall Bundle 2
Palo Alto Networks VM-Series Next-Generation Firewall Bundle 2 [VM-300]
Palo Alto Networks VM-Series Next-Generation Firewall (BYOL)
Check Point CloudGuard IaaS Next-Gen Firewall w. Threat Prevention &amp; SandBlast BYOL
Check Point CloudGuard IaaS Next-Gen Firewall with Threat Prevention
Check Point CloudGuard IaaS All-In-One
Fortinet FortiGate Next-Generation Firewall
Fortinet FortiGate (BYOL) Next-Generation Firewall
Aviatrix FQDN Egress Filtering
```

Make sure you are subscribed to the used image in the AWS Marketplace.

The following variables are optional:

key | default | value
:--- | :--- | :---
name | avx-\<region\>-firenet | Provide a custom name for VPC and Gateway resources. Result will be avx-\<name\>-firenet.
instance_size | c5.xlarge | Size of the transit gateway instances
firewall_image_version | latest | The software version to be used to deploy the NGFW's
fw_instance_size | c5.xlarge | Size of the firewall instances
fw_amount | 2 | The amount of NGFW instances to deploy. These will be deployed accross multiple AZ's. Amount must be even and only applies to when ha_gw enabled.
ha_gw | true | Set to false to deploy single Aviatrix gateway. When set to false, fw_amount is ignored and only a single NGFW instance is deployed.
attached | true | Attach firewall instances to Aviatrix Gateways.
inspection_enabled | true | Enable/disable east/west + north/south inspection via NGFW.
egress_enabled | false | Enable/disable internet egress via NGFW.
iam_role_1 | null | IAM Role used to access bootstrap bucket. (If iam_role_2 is not set, this will used for all NGFW instances)
iam_role_2 | null | IAM Role used to access bootstrap bucket. (Only used if 2 or more FW instances are deployed, e.g. when ha_gw is true. Applies to "even" fw instances (2,4,6 etc))
bootstrap_bucket_name_1 | null | Name of bootstrap bucket to pull firewall config from. (If bootstrap_bucket_name_2 is not set, this will used for all NGFW instances)
bootstrap_bucket_name_2 | null | Name of bootstrap bucket to pull firewall config from. (Only used if 2 or more FW instances are deployed, e.g. when ha_gw is true. Applies to "even" fw instances (2,4,6 etc))
insane_mode | false | Set to true to enable insane mode encryption
az1 | "a" | concatenates with region to form az names. e.g. eu-central-1a. Only used for insane mode and AWS GWLB.
az2 | "b" | concatenates with region to form az names. e.g. eu-central-1b. Only used for insane mode and AWS GWLB.
connected_transit | true | Allows spokes to run traffic to other spokes via transit gateway
hybrid_connection | false | Sign of readiness for TGW connection
bgp_manual_spoke_advertise_cidrs | | Intended CIDR list to advertise via BGP. Example: "10.2.0.0/16,10.4.0.0/16" 
learned_cidr_approval | false | Switch to true to enable learned CIDR approval
active_mesh | true | Set to false to disable Active Mesh mode for the transit gateway
prefix | true | Boolean to enable prefix name with avx-
suffix | true | Boolean to enable suffix name with -firenet
enable_segmentation | false | Switch to true to enable transit segmentation
single_az_ha | true | Set to false if Controller managed Gateway HA is desired
single_ip_snat | false | Enable single_ip mode Source NAT for this gateway
enable_advertise_transit_cidr  | false | Switch to enable/disable advertise transit VPC network CIDR for a VGW connection
bgp_polling_time  | 50 | BGP route polling time. Unit is in seconds
bgp_ecmp  | false | Enable Equal Cost Multi Path (ECMP) routing for the next hop
local_as_number | | Changes the Aviatrix Transit Gateway ASN number before you setup Aviatrix Transit Gateway connection configurations.
enable_bgp_over_lan | false | Enable BGP over LAN. Creates eth4 for integration with SDWAN for example
enable_egress_transit_firenet | false | Set to true to enable egress on transit gw
keep_alive_via_lan_interface_enabled | false | Enable Keep Alive via Firewall LAN Interface
use_gwlb | false | Use AWS GWLB (Only supported with Palo Alto NGFW)
enable_encrypt_volume | false | Set to true to enable EBS volume encryption for Gateway.
customer_managed_keys | null | Customer managed key ID for EBS Volume encryption.
tunnel_detection_time | null | The IPsec tunnel down detection time for the Spoke Gateway in seconds. Must be a number in the range [20-600]. Default is 60.
tags | null | Map of tags to assign to the gateway.
enable_multi_tier_transit |	false |	Switch to enable multi tier transit
egress_static_cidrs | [] | List of egress static CIDRs. Egress is required to be enabled. Example: ["1.171.15.184/32", "1.171.15.185/32"].
firewall_image_id | | Custom Firewall image ID.
learned_cidrs_approval_mode | | Learned cidrs approval mode. Defaults to Gateway. Valid values: gateway, connection

### Outputs
This module will return the following objects:

key | description
:--- | :---
vpc | The created VPC as an object with all of it's attributes. This was created using the aviatrix_vpc resource.
transit_gateway | The created Aviatrix transit gateway as an object with all of it's attributes.
aviatrix_firenet | The created Aviatrix firenet object with all of it's attributes.
aviatrix_firewall_instance | A list of the created firewall instances and their attributes.
