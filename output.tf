output "vpc" {
  value = aviatrix_vpc.default
}

output "transit_gateway" {
  value = var.ha_gw ? aviatrix_transit_gateway.ha[0] : aviatrix_transit_gateway.single[0]
}

output "aviatrix_firenet" {
  value = var.ha_gw ? aviatrix_firenet.firenet_ha[0] : aviatrix_firenet.firenet[0]
}

output "aviatrix_firewall_instance" {
  value = var.ha_gw ? [aviatrix_firewall_instance.firewall_instance_1[0],aviatrix_firewall_instance.firewall_instance_2[0]] : [aviatrix_firewall_instance.firewall_instance[0]]
}



