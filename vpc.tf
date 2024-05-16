module "label_vpc" {
  source     = "cloudposse/label/null"
  namespace   = "feuji"
  stage       = "test"
  version    = "0.25.0"
  context    = module.base_label.context
  name       = "vpc"
  attributes = ["main"]
}
module "label_igw" {
  source     = "cloudposse/label/null"
  namespace   = "feuji"
  stage       = "test"
  version    = "0.25.0"
  context    = module.base_label.context
  name       = "igw"
  attributes = ["main"]
}
module "label_public_route" {
  source     = "cloudposse/label/null"
  namespace   = "feuji"
  stage       = "test"
  version    = "0.25.0"
  context    = module.base_label.context
  name       = "route"
  attributes = ["public"]
}
module "labels_subnet_default" {
  source  = "cloudposse/label/null"
  version =  "0.25.0"
 
  namespace       = "feuji"
  stage           = "test"
  name            = "subnetaz"
  attributes      = ["availability-zone"]
    tags            = {}
  label_order     = ["name", "stage", "namespace", "attributes"]
  
}
module "label_private_route" {
  source     = "cloudposse/label/null"
  namespace   = "feuji"
  stage       = "test"
  version    = "0.25.0"
  context    = module.base_label.context
  name       = "route"
  attributes = ["private"]
}
module "label_public_subnet" {
  source = "cloudposse/label/null"

  namespace   = "feuji"
  stage       = "test"
  name        = "subnet"
  version    = "0.25.0"
  attributes  = ["public"]

  delimiter = "-"
  tags = {
    ManagedBy = "Terraform"
  }
}
module "label_private_subnet" {
  source = "cloudposse/label/null"

  namespace   = "feuji"
  stage       = "test"
  name        = "subnet"
  version    = "0.25.0"
  attributes  = ["private"]

  delimiter = "-"
  tags = {
    ManagedBy = "Terraform"
  }
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

# Data source to fetch available AZs
data "aws_availability_zones" "available" {
  state = "available"
}



# Manually creating subnets without using an external module
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, 0)  # Example CIDR calculation
  availability_zone = data.aws_availability_zones.available.names[0]
  

  map_public_ip_on_launch = true
  tags = module.label_public_subnet.tags
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, 1)  # Example CIDR calculation
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false
  tags = module.label_private_subnet.tags
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = module.label_igw.tags
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = module.label_public_route.tags
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public.id
}
