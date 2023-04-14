output "redurl" {
    value = aws_instance.red.public_ip
  }

output "greenurl" {
    value = aws_instance.green.public_ip
  }