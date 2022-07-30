locals {
  name = "tf-worker-${var.env}"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.ami_filter]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = [var.ami_owner]
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_key_pair" "main" {
  key_name   = local.name
  public_key = var.public_key != null ? var.public_key : file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "ssh_in" {
  name        = local.name
  description = "Allow SSH inbound traffic"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_cidr_blocks
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

data "cloudinit_config" "worker" {
  gzip          = false
  base64_encode = true

  # systemd section
  part {
    filename     = "terraform.sh"
    content_type = "text/x-shellscript"
    content      = file("${path.module}/user_data/terraform_setup.sh")
  }
}

resource "aws_instance" "worker" {
  ami              = var.ami_id != null ? var.ami_id : data.aws_ami.ubuntu.id
  instance_type    = var.instance_type
  key_name         = aws_key_pair.main.id
  subnet_id        = var.subnet_id != null ? var.subnet_id : data.aws_subnets.default.ids[0]
  user_data_base64 = data.cloudinit_config.worker.rendered

  security_groups = [aws_security_group.ssh_in.id]

  connection {
    type  = "ssh"
    user  = var.ami_username
    host  = self.public_ip != "" ? self.public_ip : self.private_ip
    agent = true
  }

  provisioner "remote-exec" {
    inline = [
      "tail -f ${var.cloud_init_log} | sed '/^SUCCESS!$/ q'"
    ]
  }

  tags = merge({ Name : local.name }, var.tags)
}
