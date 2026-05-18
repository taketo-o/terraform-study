############################
# EC2
############################
resource "aws_instance" "springboot" {
  ami                    = "ami-0f18986364089c4ab"
  instance_type          = "t2.small"
  key_name               = var.key_pair_name
  subnet_id              = aws_subnet.public_1a.id
  vpc_security_group_ids = [aws_security_group.ec2.id]

  tags = {
    Name = "SpringBootServer"
  }
}