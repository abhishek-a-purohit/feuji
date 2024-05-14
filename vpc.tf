module "label_vpc" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  context    = module.base_label.context
  name       = "vpc"
  attributes = ["main"]
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = module.label_vpc.tags
}

# =========================
# Create your subnets here
# =========================
module "subnets" {
  source  = "hashicorp/subnets/cidr"
  version = "~> 2.0"

  base_cidr_block = var.vpc_cidr
  netmask_lengths = {
    public  = 24
    private = 24
  }
  availability_zones = [data.aws_availability_zones.available.names[0]]
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = module.subnets.cidr_blocks["public"][0]
  availability_zone = data.aws_availability_zones.available.names[0]

  map_public_ip_on_launch = true
  tags = module.label_vpc.tags
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = module.subnets.cidr_blocks["private"][0]
  availability_zone = data.aws_availability_zones.available.names[0]

  map_public_ip_on_launch = false
  tags = module.label_vpc.tags
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = module.label_vpc.tags
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = module.label_vpc.tags
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public.id
}
