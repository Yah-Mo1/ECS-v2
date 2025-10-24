resource "aws_eip" "nat_eip" {
  #   vpc        = true
  count      = length(data.aws_availability_zones.available.names)
  depends_on = [aws_internet_gateway.this]
}

# NAT
resource "aws_nat_gateway" "this" {
  count         = length(data.aws_availability_zones.available.names)
  allocation_id = element(aws_eip.nat_eip.*.id, count.index)
  subnet_id     = element(aws_subnet.public_subnet.*.id, count.index)
  tags = {
    Name        = "nat"
    Environment = "${var.env}"
  }
  depends_on = [aws_internet_gateway.this, aws_eip.nat_eip]
}