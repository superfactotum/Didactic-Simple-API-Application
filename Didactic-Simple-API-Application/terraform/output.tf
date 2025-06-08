output "vpc_id" {
  description = "The ID of the created VPC."
  value       = aws_vpc.app_vpc.id
}

output "public_subnet_id" {
  description = "The ID of the public subnet."
  value       = aws_subnet.public_subnet.id
}

output "api_app_vm_id" {
  description = "The ID of the EC2 instance (api_app_vm)."
  value       = aws_instance.api_app_vm.id
}

output "api_app_vm_public_ip" {
  description = "The public IP address of the api_app_vm."
  value       = aws_eip.api_app_eip.public_ip
}

output "api_app_vm_elastic_ip_id" {
  description = "The ID of the Elastic IP associated with api_app_vm."
  value       = aws_eip.api_app_eip.id
}
