# vpc
resource "aws_vpc" "hf-msk-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags                 = { Name = "hf-msk-vpc" }
}

# security group
resource "aws_security_group" "sg_ec2" {
  vpc_id      = aws_vpc.hf-msk-vpc.id
  description = "Allow ssh"
  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "schema registry"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags        = {
    Name = "allow ssh"
  }
}

resource "aws_security_group" "sg_msk" {
  vpc_id      = aws_vpc.hf-msk-vpc.id
  description = "Allow ec2 access"
  ingress {
    from_port       = 0
    protocol        = "-1"
    to_port         = 0
    security_groups = [aws_security_group.sg_ec2.id]
  }
  ingress {
    description = "kafka brokers"
    from_port   = 9092
    to_port     = 9098
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "zookeeper"
    from_port   = 2181
    to_port     = 2182
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Allow kafka inbound"
  }
}

# internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.hf-msk-vpc.id
}

# route table
resource "aws_route_table" "hf-msk-route-table" {
  vpc_id = aws_vpc.hf-msk-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw.id
  }

  tags = { Name = "hf-msk-route-table" }
}

# subnets
resource "aws_subnet" "hf-msk-subnet1-public" {
  cidr_block        = "10.0.0.0/24"
  vpc_id            = aws_vpc.hf-msk-vpc.id
  availability_zone = "eu-west-1a"
  tags              = { Name = "hf-msk-subnet1-public" }
}

resource "aws_subnet" "hf-msk-subnet2-public" {
  cidr_block        = "10.0.1.0/24"
  vpc_id            = aws_vpc.hf-msk-vpc.id
  availability_zone = "eu-west-1b"
  tags              = { Name = "hf-msk-subnet2-public" }
}

resource "aws_subnet" "hf-msk-subnet3-public" {
  cidr_block        = "10.0.2.0/24"
  vpc_id            = aws_vpc.hf-msk-vpc.id
  availability_zone = "eu-west-1c"
  tags              = { Name = "hf-msk-subnet3-public" }
}
# associate subnet with route table
resource "aws_route_table_association" "subnet1-routetable" {
  subnet_id      = aws_subnet.hf-msk-subnet1-public.id
  route_table_id = aws_route_table.hf-msk-route-table.id
}
resource "aws_route_table_association" "subnet2-routetable" {
  subnet_id      = aws_subnet.hf-msk-subnet2-public.id
  route_table_id = aws_route_table.hf-msk-route-table.id
}
resource "aws_route_table_association" "subnet3-routetable" {
  subnet_id      = aws_subnet.hf-msk-subnet3-public.id
  route_table_id = aws_route_table.hf-msk-route-table.id
}

# network interface
resource "aws_network_interface" "ni" {
  subnet_id       = aws_subnet.hf-msk-subnet3-public.id
  private_ips     = ["10.0.2.50"]
  security_groups = [aws_security_group.sg_ec2.id]
}

# elastic ip
resource "aws_eip" "eip" {
  vpc                       = true
  network_interface         = aws_network_interface.ni.id
  associate_with_private_ip = "10.0.2.50"
  depends_on                = [aws_internet_gateway.gw]
}

#s3 vpc endpoint
resource "aws_vpc_endpoint" "s3-vpc-endpoint" {
  vpc_id            = aws_vpc.hf-msk-vpc.id
  service_name      = "com.amazonaws.eu-west-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.hf-msk-route-table.id]

  tags = {
    Name    = "s3-vpc-endpoint"
    Pricing = "hf"
  }
}

output "eip" {
  description = "ec2 elastic ip"
  value       = aws_eip.eip.public_ip
}