# DB 
resource "aws_db_instance" "main" {
  identifier           = "myapp-main-db"
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0.42"
  instance_class       = "db.t3.micro" 
  db_name              = "myappdb"
  username             = "admin"
  password             = var.db_password
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  publicly_accessible  = false

  # High Availability Configuration
  multi_az             = true

  # These link it to existing networking and security
  vpc_security_group_ids = [aws_security_group.DB_SG.id]
  db_subnet_group_name   = aws_db_subnet_group.dbsg.name
  tags = {
    Name = "myapp-db-instance"
  }
}