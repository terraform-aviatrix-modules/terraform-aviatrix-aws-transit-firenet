output "vpc" {
    value = aviatrix_vpc.default
}

output "transit_gateway_name" {
    value = var.ha_gw ? aviatrix_transit_gateway.ha.gw_name : aviatrix_transit_gateway.single.gw_name
    #value = aviatrix_transit_gateway.single
}