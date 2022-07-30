output "public_ip" {
  value = aws_instance.worker.public_ip
}

output "private_ip" {
  value = aws_instance.worker.private_ip
}

output "ssh_connection" {
  value = "${var.ami_username}@${aws_instance.worker.public_ip != "" ? aws_instance.worker.public_ip : aws_instance.worker.private_ip}"
}
