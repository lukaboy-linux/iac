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
  profile = "default"
  region = var.regiao_aws

#  shared_config_files      = ["~/.aws/config"]
#  shared_credentials_files = ["~/.aws/credentials"]


}

# resource "aws_instance" "app_server"
# ami = "ami-053b0d53c279acc90"
resource "aws_launch_template" "maquina" {
  image_id = "ami-053b0d53c279acc90"
  instance_type = var.instancia
  key_name = var.chave
  # user_data = "${file("init.sh")}"
  # user_data_replace_on_change = true
  tags = {
    Name = "TerraformAnsiblePython"
  }
}

resource "aws_key_pair" "chaveSSH" {
  key_name = var.chave
  public_key = file("${var.chave}.pub")
  
}

output "IP_publico" {
  value = aws_instance.app_server.public_ip
  
}