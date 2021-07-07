terraform {
  required_version = ">= 0.12.26"
  required_providers {
    aws    = ">= 2.66"
    random = ">= 2.2"
  }
}

# These aws_instances will be targeted with the operating_system control and the
# reachable_other_host control
resource "aws_instance" "remote_group" {
  ami           = var.instances_ami
  count         = 2
  instance_type = "t2.micro"
  key_name      = aws_key_pair.extensive_tutorial.key_name
  subnet_id     = aws_subnet.extensive_tutorial.id

  tags = {
    Name      = "kitchen-terraform-test-target-${count.index}"
    Terraform = "true"
  }

  vpc_security_group_ids = [aws_security_group.extensive_tutorial.id]
}

# The reachable_other_host control will attempt to connect to this aws_instance
# from each of the remote_group aws_instances which will verify the configuration
# of the associated aws_security_group
resource "aws_instance" "reachable_other_host" {
  ami                         = var.instances_ami
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.extensive_tutorial.key_name
  subnet_id                   = aws_subnet.extensive_tutorial.id

  tags = {
    Name      = "kitchen-terraform-reachable-other-host"
    Terraform = "true"
  }

  vpc_security_group_ids = [aws_security_group.extensive_tutorial.id]
}

resource "aws_key_pair" "extensive_tutorial" {
  key_name = "kitchen-terraform-${random_string.key_name.result}"

  public_key = var.key_pair_public_key
}

resource "random_string" "key_name" {
  length  = 9
  special = false
}

resource "aws_security_group" "extensive_tutorial" {
  description = "Allow all inbound traffic"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  name = "kitchen-terraform-extensive_tutorial"

  tags = {
    Name      = "kitchen-terraform-extensive_tutorial"
    Terraform = "true"
  }

  vpc_id = aws_vpc.extensive_tutorial.id
}

resource "aws_route_table_association" "extensive_tutorial" {
  route_table_id = aws_route_table.extensive_tutorial.id
  subnet_id      = aws_subnet.extensive_tutorial.id
}

resource "aws_route_table" "extensive_tutorial" {
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.extensive_tutorial.id
  }

  tags = {
    Name = "kitchen_terraform_extensive_tutorial"
  }

  vpc_id = aws_vpc.extensive_tutorial.id
}

resource "aws_internet_gateway" "extensive_tutorial" {
  tags = {
    Name = "kitchen_terraform_extensive_tutorial"
  }

  vpc_id = aws_vpc.extensive_tutorial.id
}

resource "aws_subnet" "extensive_tutorial" {
  availability_zone       = var.subnet_availability_zone
  cidr_block              = "192.168.1.0/24"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "kitchen_terraform_extensive_tutorial"
  }

  vpc_id = aws_vpc.extensive_tutorial.id
}

resource "aws_vpc" "extensive_tutorial" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_hostnames = "true"

  tags = {
    Name = "kitchen_terraform_extensive_tutorial"
  }
}
