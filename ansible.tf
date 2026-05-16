resource "local_file" "ansible_inventory" {
  content = <<EOT
[web]
${aws_instance.springboot.public_ip} ansible_user=ec2-user 
EOT

  filename = "${path.module}/ansible/inventory.ini"
}