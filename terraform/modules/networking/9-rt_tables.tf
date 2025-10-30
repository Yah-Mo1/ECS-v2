//Create public route table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Environment = var.env
  }
}

//Create private route table for the nat gateway routes
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.this.id
  count  = length(data.aws_availability_zones.available.names)

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.this.*.id, count.index)
  }



  tags = {
    Environment = var.env
  }
}


//Associate public route table with public subnets
resource "aws_route_table_association" "public_rt_association" {
  count          = length(data.aws_availability_zones.available.names)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

//Associate private route table with private subnets
resource "aws_route_table_association" "private_rt_association" {
  count          = length(data.aws_availability_zones.available.names)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_rt[count.index].id
}