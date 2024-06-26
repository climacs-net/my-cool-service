provider "aws" {
  region = "us-west-2"
}

resource "aws_key_pair" "deployer" {
  count = length(data.aws_key_pair.existing.key_name) == 0 ? 1 : 0
  key_name   = "terraform_aws_key"
  public_key = file("~/.ssh/id_ed25519.pub")
}

resource "aws_security_group" "my_cool_service_sg" {
  name        = "my_cool_service_sg"
  description = "Allow all inbound traffic"
  vpc_id      = "YOUR_VPC_ID"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "my_cool_service" {
  ami           = "ami-04505e74c0741db8d" # Ubuntu 22.04 LTS AMI
  instance_type = "t3.medium"
  key_name      = aws_key_pair.deployer.key_name
  security_groups = [aws_security_group.my_cool_service_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y python3 python3-pip docker.io
              sudo usermod -aG docker ubuntu
              sudo curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
              sudo install minikube-linux-amd64 /usr/local/bin/minikube
              EOF

  tags = {
    Name = "MyCoolService"
  }
}

resource "aws_eip" "my_cool_service_eip" {
  instance = aws_instance.my_cool_service.id
}

resource "aws_route53_record" "my_cool_service" {
  zone_id = "Z3RUW5P7TDNES4"
  name    = "my-cool-service.climacs.net"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.my_cool_service_eip.public_ip]
}

output "instance_ip" {
  value = aws_instance.my_cool_service.public_ip
}
