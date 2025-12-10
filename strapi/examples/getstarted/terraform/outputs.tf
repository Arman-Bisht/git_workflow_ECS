# Outputs for Terraform Configuration

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.strapi_instance.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.strapi_instance.public_ip
}

output "strapi_url" {
  description = "URL to access Strapi application"
  value       = "http://${aws_instance.strapi_instance.public_ip}:1337"
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ${var.key_name}.pem ec2-user@${aws_instance.strapi_instance.public_ip}"
}

