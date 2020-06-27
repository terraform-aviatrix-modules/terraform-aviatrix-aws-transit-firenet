output "vpc" {
  value = aviatrix_vpc.default
}

output "transit_gateway" {
  value = var.ha_gw ? aviatrix_transit_gateway.ha[0] : aviatrix_transit_gateway.single[0]
  #value = aviatrix_transit_gateway.single
}