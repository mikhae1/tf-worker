variable "env" {
  default = "PoC"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "network_interface_id" {
  type    = string
  default = null
}

variable "ami_id" {
  type    = string
  default = null
}

variable "ami_username" {
  default = "ubuntu"
}

variable "ami_filter" {
  default = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
}

variable "ami_owner" {
  default = "099720109477"
}

variable "cloud_init_log" {
  default = "/var/log/cloud-init-output.log"
}

variable "public_key" {
  type    = string
  default = null
}

variable "subnet_id" {
  type    = string
  default = null
}

variable "ssh_cidr_blocks" {
  default = ["0.0.0.0/0"]
}

variable "tags" {
  default = {
    AppId = "tf-worker"
  }
}
