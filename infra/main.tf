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
  region  = var.regiao_aws
}

# resource "aws_instance" "app_server"
# ami = "ami-053b0d53c279acc90"
resource "aws_launch_template" "maquina" {
  image_id      = "ami-0f8e81a3da6e2510a"
  instance_type = var.instancia
  key_name      = var.chave
  tags = {
    Name = "TerraformAnsiblePython"
  }
  security_group_names = [var.grupoDeSeguranca]
  user_data            = filebase64("ansible.sh")
}

resource "aws_key_pair" "chaveSSH" {
  key_name   = var.chave
  public_key = file("${var.chave}.pub")

}

resource "aws_autoscaling_group" "grupo" {
  availability_zones = ["${var.regiao_aws}b", "${var.regiao_aws}c"]
  name               = var.nomeGrupo
  max_size           = var.maximo
  min_size           = var.minimo
  target_group_arns  = [aws_lb_target_group.alvoLoadBalancer.arn]
  launch_template {
    id      = aws_launch_template.maquina.id
    version = "$Latest"
  }
}

resource "aws_default_subnet" "subnet_1" {
  availability_zone = "${var.regiao_aws}b"
}

resource "aws_default_subnet" "subnet_2" {
  availability_zone = "${var.regiao_aws}c"
}

resource "aws_lb" "loadBalancer" {
  internal        = false
  subnets         = [aws_default_subnet.subnet_1.id, aws_default_subnet.subnet_2.id]
  security_groups = [aws_security_group.acesso_geral.id]
}

resource "aws_default_vpc" "vpc" {
}

resource "aws_lb_target_group" "alvoLoadBalancer" {
  name     = "alvoLoadBalancer"
  port     = "8000"
  protocol = "HTTP"
  vpc_id   = aws_default_vpc.vpc.id
}

resource "aws_lb_listener" "entradaLoadBalancer" {
  load_balancer_arn = aws_lb.loadBalancer.arn
  port              = "8000"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alvoLoadBalancer.arn
  }
}

resource "aws_autoscaling_policy" "escala-Producao" {
  name                   = "terraform-escala"
  autoscaling_group_name = var.nomeGrupo
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}
