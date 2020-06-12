output "vpc" {
    value = aviatrix_vpc.default
}

output "transit_gateway" {
    value = var.ha_gw ? aviatrix_transit_gateway.ha : aviatrix_transit_gateway.single
}