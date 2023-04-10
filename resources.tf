
## create keypair
resource "aws_key_pair" "deployer" {
  key_name   = "terraform3"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCyNRL9nyxUnjeqSr92yVqV4ImkfwR6qYQrBBR5+eaxrCDQhIoHUtgiG0YXjrhXl6E6ErKiZBgwGjjFsMqjdzsfS9kHiawTMxTr4ilwCfOChgDfR5t5e3L/X4F/ZjCZiK1qNha+/DC5r/dGwhB579yxXSUxVWfGOP4buGWkWBWpmrN94EMmtFdyBSjnjMardSV2mXXPjPDNDudDUMEsQr4P8aAbiOj9VCf2tpQswElkjA4IZ8DfIfeIwKYsR11uDAqZrSf96TxFXN6OCKOnqu4DSWxFbKywffS5XG+nTC1+oee/ftdL6rlJpg/VaTN4Bqfsk9px/redvXlNFUsaZqrm5UiLCS7QGO/HfPa57JQBsS+jv2fURQfYMg35otxtbE3+IIHLzmdNnQOVU/scTyuO73kHrU2w0zTqfbMbqm7CqpnBfrdyzI4+AnV/4HtYojxGTZR6S3oV0azc7eKAGyeUjMttTuVbDYlQInkvZvS4SrFSfRTk+v1CFX0IJvSlVFE= dell@DESKTOP-G8OJBDS"
}

## create EC2 instance
resource "aws_instance" "red" {
  instance_type               = "t2.micro"
  associate_public_ip_address = "true"
  ami                         = "ami-007855ac798b5175e"
  subnet_id                   = aws_subnet.lb_subnet[0].id
  vpc_security_group_ids      = [aws_security_group.terraformlb.id]
  key_name                    = "terraform3"
  tags = {
    Name = "red"
  }
  depends_on = [
    aws_security_group.terraformlb
  ]
}

## create null resoure
resource "null_resource" "spc" {
  triggers = {
    rollout_versions = var.lb_vpc_info.rollout_versions
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    host        = aws_instance.red.public_ip
  }
  provisioner "file" {
    source      = "./spc.service"
    destination = "/home/ubuntu/spc.service"

  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install openjdk-17-jdk maven -y",
      "sudo cp /home/ubuntu/spc.service /etc/systemd/system/spc.service",
      "git clone https://github.com/spring-projects/spring-petclinic.git",
      "cd spring-petclinic",
      "./mvnw package",
      "sudo systemctl daemon-reload",
      "sudo systemctl start spc.service"
    ]
  }
}

