variable "aws_region" {
  description = "AWS region to deploy resources."
  type        = string
  default     = "eu-west-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  description = "CIDR block for the public subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_az" {
  description = "Availability Zone for the public subnet."
  type        = string
  default     = "eu-west-1a"
}

variable "ec2_instance_ami" {
  description = "AMI ID for the EC2 instance. Verify the latest for your region."
  type        = string
  default     = "ami-0d729a60ca855308d" # Ubuntu Server 22.04 LTS for eu-west-1
}

variable "ec2_instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t2.micro"
}

variable "ec2_key_pair_name" {
  description = "Name of the EC2 key pair to associate with the instance for SSH access."
  type        = string
  # This should be provided by the user.
}
