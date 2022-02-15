# Aviatrix Transit Firenet VPC for AWS

### Description
This module deploys a VPC, Aviatrix transit gateways and firewall instances.

### Compatibility
Module version | Terraform version | Controller version | Terraform provider version
:--- | :--- | :--- | :---
v5.0.0 | 0.13 - 1.x | >=6.6 | 2.21.0-6.6.ga
v4.0.3 | 0.13 + 0.14 | >=6.4 | >=0.2.19.2
v4.0.2 | 0.13 + 0.14 | >=6.4 | >=0.2.19
v4.0.1 | 0.13 + 0.14 | >=6.4 | >=0.2.19
v3.0.5 | 0.13 | >=6.3 | >=0.2.18

**_Information on older releases can be found in respective release notes._*

### Diagram
<img src="https://github.com/terraform-aviatrix-modules/terraform-aviatrix-aws-transit-firenet/blob/master/img/module-transit-firenet-ha.png?raw=true">

with ha_gw set to false, the following will be deployed:

<img src="https://github.com/terraform-aviatrix-modules/terraform-aviatrix-aws-transit-firenet/blob/master/img/module-transit-firenet.png?raw=true">

### Usage Example
```
module "transit_firenet_1" {
  source  = "terraform-aviatrix-modules/aws-transit-firenet/aviatrix"
  version = "5.0.0"
  
  cidr           = "10.1.0.0/20"
  region         = "eu-west-1"
  account        = "AWS"
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
attached | true | Attach firewall instances to Aviatrix Gateways.
az1 | "a" | concatenates with region to form az names. e.g. eu-central-1a. Only used for insane mode and AWS GWLB.
az2 | "b" | concatenates with region to form az names. e.g. eu-central-1b. Only used for insane mode and AWS GWLB. If az1 and az2 are equal. Single AZ mode (deploy everyting in 1 AZ) is triggered.
bgp_ecmp  | false | Enable Equal Cost Multi Path (ECMP) routing for the next hop
bgp_manual_spoke_advertise_cidrs | | Intended CIDR list to advertise via BGP. Example: "10.2.0.0/16,10.4.0.0/16" 
bgp_polling_time  | 50 | BGP route polling time. Unit is in seconds
bootstrap_bucket_name_1 | null | Name of bootstrap bucket to pull firewall config from. (If bootstrap_bucket_name_2 is not set, this will used for all NGFW instances)
bootstrap_bucket_name_2 | null | Name of bootstrap bucket to pull firewall config from. (Only used if 2 or more FW instances are deployed, e.g. when ha_gw is true. Applies to "even" fw instances (2,4,6 etc))
china | false | Set to true if deploying this module in AWS/Azure China.
connected_transit | true | Allows spokes to run traffic to other spokes via transit gateway
deploy_firenet | true | Set to false to only deploy the Transit, but without the actual NGFW instances and Firenet settings (e.g. if you want to deploy that later or manually).
customer_managed_keys | null | Customer managed key ID for EBS Volume encryption.
east_west_inspection_excluded_cidrs | | Network List Excluded From East-West Inspection.
egress_enabled | false | Enable/disable internet egress via NGFW.
egress_static_cidrs | [] | List of egress static CIDRs. Egress is required to be enabled. Example: ["1.171.15.184/32", "1.171.15.185/32"].
enable_advertise_transit_cidr  | false | Switch to enable/disable advertise transit VPC network CIDR for a VGW connection
enable_bgp_over_lan | false | Enable BGP over LAN. Creates eth4 for integration with SDWAN for example
enable_egress_transit_firenet | false | Set to true to enable egress on transit gw
enable_encrypt_volume | false | Set to true to enable EBS volume encryption for Gateway.
enable_multi_tier_transit |	false |	Switch to enable multi tier transit
enable_segmentation | false | Switch to true to enable transit segmentation
fail_close_enabled | | Set to true to enable fail close
firewall_image_id | | Custom Firewall image ID.
firewall_image_version | latest | The software version to be used to deploy the NGFW's
fw_amount | 2 | The amount of NGFW instances to deploy. These will be deployed accross multiple AZ's. Amount must be even and only applies to when ha_gw enabled.
fw_instance_size | c5.xlarge | Size of the firewall instances
fw_tags | null | Map of tags to assign to the firewall or FQDN egress gw's.
gov | false | Set to true when deploying this module in AWS GOV
ha_gw | true | Set to false to deploy single Aviatrix gateway. When set to false, fw_amount is ignored and only a single NGFW instance is deployed.
hybrid_connection | false | Sign of readiness for TGW connection
iam_role_1 | null | IAM Role used to access bootstrap bucket. (If iam_role_2 is not set, this will used for all NGFW instances)
iam_role_2 | null | IAM Role used to access bootstrap bucket. (Only used if 2 or more FW instances are deployed, e.g. when ha_gw is true. Applies to "even" fw instances (2,4,6 etc))
insane_mode | false | Set to true to enable insane mode encryption
inspection_enabled | true | Enable/disable east/west + north/south inspection via NGFW.
instance_size | c5.xlarge | Size of the transit gateway instances
keep_alive_via_lan_interface_enabled | false | Enable Keep Alive via Firewall LAN Interface
learned_cidr_approval | false | Switch to true to enable learned CIDR approval
learned_cidrs_approval_mode | | Learned cidrs approval mode. Defaults to Gateway. Valid values: gateway, connection
local_as_number | | Changes the Aviatrix Transit Gateway ASN number before you setup Aviatrix Transit Gateway connection configurations.
name | avx-\<region\>-firenet | Provide a custom name for VPC and Gateway resources. Result will be avx-\<name\>-firenet.
prefix | true | Boolean to enable prefix name with avx-
single_az_ha | true | Set to false if Controller managed Gateway HA is desired
single_ip_snat | false | Enable single_ip mode Source NAT for this gateway
suffix | true | Boolean to enable suffix name with -firenet
tags | null | Map of tags to assign to the gateway.
tunnel_detection_time | null | The IPsec tunnel down detection time for the Spoke Gateway in seconds. Must be a number in the range [20-600]. Default is 60.
use_gwlb | false | Use AWS GWLB (Only supported with Palo Alto NGFW)
user_data_1 | | User data for bootstrapping Fortigate and Checkpoint firewalls. (If user_data_2 is not set, this will used for all NGFW instances)
user_data_2 | | User data for bootstrapping Fortigate and Checkpoint firewalls. (Only used if 2 or more FW instances are deployed, e.g. when ha_gw is true. Applies to "even" fw instances (2,4,6 etc))

### Outputs
This module will return the following objects:

key | description
:--- | :---
[vpc](https://registry.terraform.io/providers/AviatrixSystems/aviatrix/latest/docs/resources/aviatrix_vpc) | The created VPC as an object with all of it's attributes. This was created using the aviatrix_vpc resource.
[transit_gateway](https://registry.terraform.io/providers/AviatrixSystems/aviatrix/latest/docs/resources/aviatrix_transit_gateway) | The created Aviatrix transit gateway as an object with all of it's attributes.
[aviatrix_firenet](https://registry.terraform.io/providers/AviatrixSystems/aviatrix/latest/docs/resources/aviatrix_firenet) | The created Aviatrix firenet object with all of it's attributes.
[aviatrix_firewall_instance](https://registry.terraform.io/providers/AviatrixSystems/aviatrix/latest/docs/resources/aviatrix_firewall_instance) | A list of the created firewall instances and their attributes.
