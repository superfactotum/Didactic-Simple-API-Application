provider "aws" {
  region = var.aws_region
}

# 1. VPC
resource "aws_vpc" "app_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "app-vpc-${var.aws_region}" 
  }
}

# 2. Internet Gateway
resource "aws_internet_gateway" "app_igw" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "app-igw"
  }
}

# 3. Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = var.public_subnet_cidr_block
  availability_zone       = var.public_subnet_az
  map_public_ip_on_launch = true 

  tags = {
    Name = "app-public-subnet-${var.public_subnet_az}"
  }
}

# 4. Route Table for Public Subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app_igw.id
  }

  tags = {
    Name = "app-public-rt"
  }
}

# 5. Associate Route Table with Public Subnet
resource "aws_route_table_association" "public_subnet_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# 6. Security Group for the VM
resource "aws_security_group" "api_app_sg" {
  name        = "api-app-sg"
  description = "Allow SSH and App traffic for api_app_vm"
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
    description      = "SSH from anywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] # Restrict according to security requirements
  }

  ingress {
    description      = "App traffic (Gunicorn default port)"
    from_port        = 5000 # Flask
    to_port          = 5000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] # Restrict according to security requirements
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1" # Allow all outbound traffic
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "api-app-sg"
  }
}

# 7. EC2 Instance (api_app_vm)
resource "aws_instance" "api_app_vm" {
  ami           = var.ec2_instance_ami
  instance_type = var.ec2_instance_type
  subnet_id     = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.api_app_sg.id]
  key_name      = var.ec2_key_pair_name

  tags = {
    Name = "api_app_vm"
  }
}

# 8. Elastic IP (Public IP)
resource "aws_eip" "api_app_eip" {
  
  vpc      = true 

  tags = {
    Name = "api-app-eip"
  }
  depends_on = [aws_internet_gateway.app_igw] # This gataway is not included in the code
}

# 9. Associate Elastic IP with EC2 Instance
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.api_app_vm.id
  allocation_id = aws_eip.api_app_eip.id
}
