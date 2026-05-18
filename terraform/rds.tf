############################
# RDS
############################
resource "aws_db_subnet_group" "main" {
  name = "main-db-subnet-group"

  subnet_ids = [
    aws_subnet.private_1a.id,
    aws_subnet.private_1c.id
  ]

  tags = {
    Name = "Main DB subnet group"
  }
}

resource "aws_db_instance" "mysql" {
  allocated_storage       = 20
  engine                  = "mysql"
  instance_class          = "db.t4g.micro"
  db_name                 = "awsstudy"
  username                = var.db_username
  password                = var.db_password
  publicly_accessible     = false
  backup_retention_period = 7
  multi_az                = false

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  skip_final_snapshot = true
}