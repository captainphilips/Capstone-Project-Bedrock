############################
# VPC
############################
resource "aws_vpc" "bedrock" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.tags,
    {
      Name    = "project-bedrock-vpc"
      Project = "Bedrock"
    }
  )
}

############################
# Subnets — 2 AZs × (1 public + 1 private) = 4 subnets
############################
# Public Subnets
resource "aws_subnet" "public" {
  for_each = toset(var.azs)

  vpc_id                  = aws_vpc.bedrock.id
  cidr_block              = "10.0.${index(var.azs, each.value) * 2 + 1}.0/24" # Produces 10.0.1.0/24 and 10.0.3.0/24
  availability_zone       = each.value
  map_public_ip_on_launch = true

  tags = {
    Name                                            = "project-bedrock-public-${each.value}"
    Project                                         = "Bedrock"
    "kubernetes.io/cluster/project-bedrock-cluster" = "shared"
    "kubernetes.io/role/elb"                        = "1"
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  for_each = toset(var.azs)

  vpc_id            = aws_vpc.bedrock.id
  cidr_block        = "10.0.${index(var.azs, each.value) * 2 + 2}.0/24" # Produces 10.0.2.0/24 and 10.0.4.0/24
  availability_zone = each.value

  tags = {
    Name                                            = "project-bedrock-private-${each.value}"
    Project                                         = "Bedrock"
    "kubernetes.io/cluster/project-bedrock-cluster" = "owned"
    "kubernetes.io/role/internal-elb"               = "1"
  }
}

############################
# Internet Gateway
############################
resource "aws_internet_gateway" "bedrock" {
  vpc_id = aws_vpc.bedrock.id

  tags = {
    Name    = "project-bedrock-igw"
    Project = "Bedrock"
  }
}

############################
# NAT Gateways (one per AZ — required so private subnets reach the internet)
############################
resource "aws_eip" "nat" {
  for_each = toset(var.azs)

  domain = "vpc"

  tags = {
    Name    = "project-bedrock-eip-${each.value}"
    Project = "Bedrock"
  }
}

resource "aws_nat_gateway" "bedrock" {
  for_each = toset(var.azs)

  allocation_id = aws_eip.nat[each.value].id
  subnet_id     = aws_subnet.public[each.value].id

  tags = {
    Name    = "project-bedrock-nat-${each.value}"
    Project = "Bedrock"
  }

  depends_on = [aws_internet_gateway.bedrock]
}

############################
# Route Tables
############################
# Public route table — route 0.0.0.0/0 → IGW
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.bedrock.id

  tags = {
    Name    = "project-bedrock-rtb-public"
    Project = "Bedrock"
  }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.bedrock.id
}

resource "aws_route_table_association" "public" {
  for_each = toset(var.azs)

  subnet_id      = aws_subnet.public[each.value].id
  route_table_id = aws_route_table.public.id
}

# Private route tables (one per AZ) — route 0.0.0.0/0 → NAT GW in same AZ
resource "aws_route_table" "private" {
  for_each = toset(var.azs)

  vpc_id = aws_vpc.bedrock.id

  tags = {
    Name    = "project-bedrock-rtb-private-${each.value}"
    Project = "Bedrock"
  }
}

resource "aws_route" "private_nat" {
  for_each = toset(var.azs)

  route_table_id         = aws_route_table.private[each.value].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.bedrock[each.value].id
}

resource "aws_route_table_association" "private" {
  for_each = toset(var.azs)

  subnet_id      = aws_subnet.private[each.value].id
  route_table_id = aws_route_table.private[each.value].id
}
