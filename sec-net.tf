#get availability zone
data "aws_availability_zones" "tf_azs" {}

#key pair for ec2
resource "aws_key_pair" "tf_auth" {
  key_name   = "deployer"
  public_key = file(var.pub_key)
}
#create vpc

resource "aws_vpc" "tf_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "tf_vpc_au"
  }
}
#create igw
resource "aws_internet_gateway" "tf_igw" {
  vpc_id = aws_vpc.tf_vpc.id
  tags = {
    Name = "tf_igw_au"
  }
}
#create route table
resource "aws_route_table" "tf_rt_public" {
  vpc_id = aws_vpc.tf_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf_igw.id
  }
  tags = {
    Name = "tf_rt_pub_au"
  }
}
resource "aws_default_route_table" "tf_rt_private" {
  default_route_table_id = aws_vpc.tf_vpc.default_route_table_id
}
#create security group
resource "aws_security_group" "tf_sg_public" {
  vpc_id = aws_vpc.tf_vpc.id
  ingress {
    to_port     = "22"
    from_port   = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    to_port     = "22"
    from_port   = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "tf_sg_pub_au"
  }
}
resource "aws_security_group" "tf_sg_private" {
  vpc_id = aws_vpc.tf_vpc.id
  ingress {
    to_port   = "3306"
    from_port = "3306"
    protocol  = "tcp"
    #cidr_blocks = [aws_subnet.tf_subnet_public.cidr_block]
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    to_port   = "3306"
    from_port = "3306"
    protocol  = "tcp"
    #cidr_blocks = [aws_subnet.tf_subnet_public.cidr_block]
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "tf_sg_pri_au"
  }
}
#create subnets

resource "aws_subnet" "tf_subnet_public" {
  vpc_id                  = aws_vpc.tf_vpc.id
  availability_zone       = data.aws_availability_zones.tf_azs.names[0]
  map_public_ip_on_launch = true
  cidr_block              = var.sub_pub_cidr
  tags = {
    Name = "tf_subnet_pub_au"
  }
}
resource "aws_subnet" "tf_subnet_private" {
  vpc_id            = aws_vpc.tf_vpc.id
  availability_zone = data.aws_availability_zones.tf_azs.names[0]
  cidr_block        = var.sub_pri_cidr1
  tags = {
    Name = "tf_subnet_pri_au"
  }
}
resource "aws_subnet" "tf_subnet_private2" {
  vpc_id            = aws_vpc.tf_vpc.id
  availability_zone = data.aws_availability_zones.tf_azs.names[1]
  cidr_block        = var.sub_pri_cidr2
  tags = {
    Name = "tf_subnet_pri_au2"
  }
}

#create rt associations
resource "aws_route_table_association" "tf_rt_pub_assoc" {
  subnet_id      = aws_subnet.tf_subnet_public.id
  route_table_id = aws_route_table.tf_rt_public.id
}
resource "aws_route_table_association" "tf_rt_priv_assoc1" {
  subnet_id      = aws_subnet.tf_subnet_private.id
  route_table_id = aws_vpc.tf_vpc.default_route_table_id
}
resource "aws_route_table_association" "tf_rt_priv_assoc2" {
  subnet_id      = aws_subnet.tf_subnet_private2.id
  route_table_id = aws_vpc.tf_vpc.default_route_table_id
}
