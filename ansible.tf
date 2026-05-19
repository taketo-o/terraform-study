resource "null_resource" "create_ansible_dir" {
  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/ansible"
  }
}

resource "local_file" "ansible_inventory" {
  depends_on = [
    null_resource.create_ansible_dir,
    aws_instance.springboot
  ]

  content = <<EOT
[web]
${aws_instance.springboot.public_ip} ansible_user=ec2-user ansible_ssh_private_key_file=${var.ssh_private_key_path}
EOT

  filename = "${path.module}/ansible/inventory.ini"
}

resource "null_resource" "run_ansible" {

  depends_on = [local_file.ansible_inventory]

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${path.module}/ansible/inventory.ini ${path.module}/ansible/import_playbook.yml"
  }
}