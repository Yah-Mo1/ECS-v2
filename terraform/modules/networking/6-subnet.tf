data "aws_availability_zones" "available" {}
//TODO


//Create public subnets for each availability zone
resource "aws_subnet" "public_subnet" {
  count                   = length(data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidr_block[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Environment = var.env
  }
}

//Create private subnets for each availability zone
resource "aws_subnet" "private_subnet" {
  count                   = length(data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.private_subnet_cidr_block[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false


  tags = {
    Environment = var.env
  }
}