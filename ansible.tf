resource "local_file" "ansible_inventory" {
  content = <<EOT

[web]
${aws_instance.springboot.public_ip} ansible_user=ec2-user ansible_ssh_private_key_file=${var.ssh_private_key_path}
EOT

  filename = "${path.module}/ansible/inventory.ini"
}