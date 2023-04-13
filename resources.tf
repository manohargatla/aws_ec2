## create keypair
resource "aws_key_pair" "deployer" {
  key_name   = "terraform3"
  public_key = file("~/.ssh/id_rsa.pub")
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
    destination = "/tmp/spc.service"

  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install openjdk-17-jdk maven -y",
      "sudo cp /tmp/spc.service /etc/systemd/system/spc.service",
      "git clone https://github.com/spring-projects/spring-petclinic.git",
      "cd spring-petclinic",
      "./mvnw package",
      "sudo systemctl daemon-reload",
      "sudo systemctl start spc.service"
    ]
  }
}

## create EC2 instance
resource "aws_instance" "green" {
  instance_type               = "t2.micro"
  associate_public_ip_address = "true"
  ami                         = "ami-007855ac798b5175e"
  subnet_id                   = aws_subnet.lb_subnet[1].id
  vpc_security_group_ids      = [aws_security_group.terraformlb.id]
  key_name                    = "terraform3"
  tags = {
    Name = "green"
  }
  depends_on = [
    aws_security_group.terraformlb
  ]
}

## create null resoure
resource "null_resource" "spc1" {
  triggers = {
    rollout_versions = var.lb_vpc_info.rollout_versions
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    host        = aws_instance.green.public_ip
  }
  provisioner "file" {
    source      = "./spc.service"
    destination = "/tmp/spc.service"

  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install openjdk-17-jdk maven -y",
      "sudo cp /tmp/spc.service /etc/systemd/system/spc.service",
      "git clone https://github.com/spring-projects/spring-petclinic.git",
      "cd spring-petclinic",
      "./mvnw package",
      "sudo systemctl daemon-reload",
      "sudo systemctl start spc.service"
    ]
  }
}