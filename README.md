# Module Aviatrix Transit VPC for AWS

This module deploys a VPC and an Aviatrix transit gateway. Defining the Aviatrix Terraform provider is assumed upstream and is not part of this module.

<img src="images/module-aviatrix-transit-vpc-for-aws.png"  height="250">


The following variables are required:

key | value
--- | ---
region | AWS region to deploy the transit VPC in
aws_account_name | The AWS accountname on the Aviatrix controller, under which the controller will deploy this VPC
cidr | The IP CIDR wo be used to create the VPC. Assumes a /16.

The following variables are optional:

key | default | value
--- | --- | ---
instance_size | t2.micro | Size of the transit gateway instances
ha_gw | false | Set to true to enable deploying an HA GW

Outputs
This module will return the following objects:

key | description
--- | ---
vpc | The created VPC as an object with all of it's attributes. This was created using the aviatrix_vpc resource.
transit_gateway | The created Aviatrix transit gateway as an object with all of it's attributes.

When ha_gw is set to true, the deployed infrastructure will look like this:

<img src="images/module-aviatrix-transit-vpc-for-aws-ha.png"  height="250">