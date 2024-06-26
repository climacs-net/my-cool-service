provider "aws" {
  region = "us-east-1"
}

data "aws_key_pair" "existing" {
  key_name = "terraform_aws_key"
  filter {
    name   = "key-name"
    values = ["terraform_aws_key"]
  }
  count = 0
}

resource "aws_key_pair" "deployer" {
  count      = length(data.aws_key_pair.existing) == 0 ? 1 : 0
  key_name   = "terraform_aws_key"
  public_key = file("~/.ssh/id_ed25519.pub")
}

locals {
  key_name = length(data.aws_key_pair.existing) == 0 ? aws_key_pair.deployer[0].key_name : "terraform_aws_key"
}

resource "aws_instance" "my_cool_service" {
  ami               = "ami-06f59e43b31a49ecc" # Ubuntu Server 24.04 LTS (HVM), update to the correct AMI for your region
  instance_type     = "t3.medium" # Specify the desired instance type
  key_name          = local.key_name
  availability_zone = "us-east-1b" # Ensure this is a valid availability zone

  root_block_device {
    volume_size = 25 # Size in GB
    volume_type = "gp2" # General Purpose SSD
  }

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

resource "aws_eip" "elastic_ip" {
  instance = aws_instance.my_cool_service.id
  vpc      = true
}

resource "aws_route53_record" "fqdn" {
  zone_id = "Z3RUW5P7TDNES4" # Replace with your actual Route 53 hosted zone ID
  name    = "my-cool-service.climacs.net" # Replace with your desired domain name
  type    = "A"
  ttl     = "300"
  records = [aws_eip.elastic_ip.public_ip]
}

output "instance_ip" {
  value = aws_eip.elastic_ip.public_ip
}
