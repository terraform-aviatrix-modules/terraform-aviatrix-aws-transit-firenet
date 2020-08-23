# Aviatrix Transit Firenet VPC for AWS

### Description
This module deploys a VPC, Aviatrix transit gateways and firewall instances.

### Diagram
<img src="https://dhagens-repository-images-public.s3.eu-central-1.amazonaws.com/terraform-aviatrix-aws-transit-firenet/module-transit-firenet.png"  height="250">

with ha_gw set to false, the following will be deployed:

<img src="https://dhagens-repository-images-public.s3.eu-central-1.amazonaws.com/terraform-aviatrix-aws-transit-firenet/module-transit-firenet-non-ha.png"  height="250">

### Usage Example
```
module "transit_firenet_1" {
  source  = "terraform-aviatrix-modules/aws-transit-firenet/aviatrix"
  version = "1.0.1"

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
```

Make sure you are subscribed to the used image in the AWS Marketplace.

The following variables are optional:

key | default | value
:--- | :--- | :---
name | avx-\<region\>-transit | Provide a custom name for VPC and Gateway resources. Result will be avx-\<name\>-transit.
instance_size | c5.xlarge | Size of the transit gateway instances
fw_instance_size | c5.xlarge | Size of the firewall instances
fw_amount | 2 | The amount of NGFW instances to deploy. These will be deployed accross multiple AZ's. Amount must be even.
ha_gw | true | Set to false to deploy single Aviatrix gateway. When set to false, fw_amount is ignored and only a single NGFW instance is deployed.
attached | true | Attach firewall instances to Aviatrix Gateways
inspection_enabled | true | 
egress_enabled | true | 
iam_role | null | IAM Role used to access bootstrap bucket.
bootstrap_bucket_name | null | Name of bootstrap bucket to pull firewall config from.
insane_mode | false | Set to true to enable insane mode encryption
az1 | "a" | concatenates with region to form az names. e.g. eu-central-1a. Used for insane mode only.
az2 | "b" | concatenates with region to form az names. e.g. eu-central-1b. Used for insane mode only.

### Outputs
This module will return the following objects:

key | description
:--- | :---
vpc | The created VPC as an object with all of it's attributes. This was created using the aviatrix_vpc resource.
transit_gateway | The created Aviatrix transit gateway as an object with all of it's attributes.
aviatrix_firenet | The created Aviatrix firenet object with all of it's attributes.
aviatrix_firewall_instance | A list of the created firewall instances and their attributes.
