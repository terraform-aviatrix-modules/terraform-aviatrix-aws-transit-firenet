output "vpc" {
  description = "The created VPC with all of it's attributes"
  value       = aviatrix_vpc.default
}

output "transit_gateway" {
  description = "The Aviatrix transit gateway object with all of it's attributes"
  value       = aviatrix_transit_gateway.default
}

output "aviatrix_firenet" {
  description = "The Aviatrix firenet object with all of it's attributes"
  value       = var.deploy_firenet ? aviatrix_firenet.firenet : null
}

# output "aviatrix_firewall_instance" {
#   description = "A list with the created firewall instances and their attributes"
#   value       = var.fw_amount > 0 ? (var.ha_gw ? (local.is_aviatrix ? [aviatrix_gateway.egress_instance_1[0], aviatrix_gateway.egress_instance_2[0]] : [aviatrix_firewall_instance.firewall_instance_1[0], aviatrix_firewall_instance.firewall_instance_2[0]]) : (local.is_aviatrix ? [aviatrix_gateway.egress_instance[0]] : [aviatrix_firewall_instance.firewall_instance[0]])) : []
# }

output "aviatrix_firewall_instance" {
  description = "A list with the created firewall instances and their attributes"
  value       = var.deploy_firenet == false ? null : (var.ha_gw ? (local.is_aviatrix ? [aviatrix_gateway.egress_instance_1[0], aviatrix_gateway.egress_instance_2[0]] : [aviatrix_firewall_instance.firewall_instance_1[0], aviatrix_firewall_instance.firewall_instance_2[0]]) : (local.is_aviatrix ? [aviatrix_gateway.egress_instance[0]] : [aviatrix_firewall_instance.firewall_instance[0]]))
}