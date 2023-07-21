terraform {
  required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~> 4.16"
        }
    }
    required_version = ">= 1.2.0"
}

provider "aws" {
  shared_config_files      = ["~/.aws/config"]
  shared_credentials_files = ["~/.aws/credentials"]

}

resource "aws_instance" "app_server" {
  ami           = "ami-053b0d53c279acc90"
  instance_type = "t2.micro"
  key_name = "ubuntu"
  user_data = <<-EOF
                 #!/bin/bash
		             cd /home/ubuntu
		             sudo echo "<h1>Feito com Terraform</h1>" > index.html
		             sudo nohup busybox httpd -f -p 8080 &
		             EOF

  tags = {
    Name = "SudoTeste"
  }
}
