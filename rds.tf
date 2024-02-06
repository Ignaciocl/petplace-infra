data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "rds" {
  vpc_id      = data.aws_vpc.default.id
  name        = "rdsPetPlace"
  description = "Allow all inbound for Postgres"
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_db_instance" "rds" {
  identifier             = "petplace"
  instance_class         = "db.t2.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "12"
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.rds.id]
  username               = "lichaNoVeasEsto"
  password               = "newUltraPassword"
}
