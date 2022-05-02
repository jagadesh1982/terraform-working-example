output "security_group" {
    value = "aws_security_group.project-iac-sg.id"
}

output "ec2instance" {
  value = aws_instance.project-iac.public_ip
}

