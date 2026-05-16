resource "local_file" "ansible_inventory" {
  content = <<EOT
[web]
${aws_instance.springboot.public_ip} ansible_user=ec2-user ansible_ssh_private_key_file=/Users/fubuki/Downloads/aws-study-key.pem
EOT

  filename = "/Users/fubuki/terraform/ansible/inventory.ini"
}