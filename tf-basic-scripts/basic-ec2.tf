provider "aws" {
    region = "ap-northeast-1"
}

########### VPC Block ###########
resource "aws_vpc" "cloudpro_vpc" {
    cidr_block = "10.0.0.0/16"
}

########### Internet Gateway ###########
resource "aws_internet_gateway" "cloudpro_igw" {
    vpc_id = aws_vpc.cloudpro_vpc.id

    tags = {
        Name = "cloudpro_igw"
  }
}

########### Subnet ###########
resource "aws_subnet" "cloudpro_subnet" {
  vpc_id     = aws_vpc.cloudpro_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "cloudpro_subnet"
  }
}

########### Route Table ###########
resource "aws_route_table" "cloudpro_rt" {
  vpc_id = aws_vpc.cloudpro_vpc.id

  route = []

  tags = {
    Name = "cloudpro_rt"
  }
}

########### Route  ###########
resource "aws_route" "r" {
  route_table_id            = aws_route_table.cloudpro_rt.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.cloudpro_igw.id
  depends_on                = [aws_route_table.cloudpro_rt]
}

########### Security Group  ###########
resource "aws_security_group" "cloudpro_sg" {
  name        = "allow_all_traffic"
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.cloudpro_vpc.id

  ingress {
    description      = "All traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_all"
  }
}

########### Route Table Association (attach subnets) ###########
resource "aws_route_table_association" "cloudpro_rta" {
  subnet_id      = aws_subnet.cloudpro_subnet.id
  route_table_id = aws_route_table.cloudpro_rt.id
}

########### EC2 Instance  ###########
resource "aws_instance" "cloudpro_ec2" {
  ami           = "ami-088da9557aae42f39"
  instance_type = "t2.micro"

  tags = {
    Name = "cloudpro_ec2"
  }
}
