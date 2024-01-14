// ToDo improve this for better security access
resource "aws_security_group" "https-fargate" {
  name = "${module.vpc.name}-https-fargate-sg"
  description = "Allow HTTPS inbound traffic for private subnet"

  vpc_id = module.vpc.vpc_id

  ingress {
    cidr_blocks = [module.vpc.vpc_cidr_block]
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  tags = {
    Name = "HTTPS access fargate"
  }
}

resource "aws_security_group" "https" {
  name = "${module.vpc.name}-https-sg"
  description = "Allow HTTP and HTTPS inbound traffic"

  vpc_id = module.vpc.vpc_id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  tags = {
    Name = "HTTP(S) access load balancer"
  }
}
