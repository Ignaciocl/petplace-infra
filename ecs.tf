resource "aws_ecs_cluster" "pet-place-cluster" {
  name = "pet-place"
}

resource "aws_ecs_service" "drugs-service" {
  name            = "drugs"
  cluster         = aws_ecs_cluster.pet-place-cluster.id
  task_definition = aws_ecs_task_definition.drugs-task-definition.arn
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups  = [aws_security_group.https-fargate.id]
    assign_public_ip = true // true for now
  }
  load_balancer {
    target_group_arn = aws_alb_target_group.main.id
    container_name   = "drugs"
    container_port   = var.container_port
  }
  desired_count = var.amount_of_tasks
}

resource "aws_ecs_task_definition" "drugs-task-definition" {
  family                   = "ecs-task-definition-drugs"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  memory                   = "512"
  cpu                      = "256"
  execution_role_arn       = aws_iam_role.ecs_task_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  container_definitions    = jsonencode([
    {
      name             = "drugs"
      image            = "058264238248.dkr.ecr.${var.region}.amazonaws.com/${aws_ecr_repository.drugs-repository.name}:latest"
      essential        = true
      logConfiguration = {
        logDriver = "awslogs",
        "options" : {
          "awslogs-create-group" : "true",
          "awslogs-group" : aws_cloudwatch_log_group.groupForEcs.id,
          "awslogs-region" : var.region,
          "awslogs-stream-prefix" : "awslogs-drugs",
        }
      },
      portMappings = [
        {
          protocol      = "tcp"
          containerPort = var.container_port
          hostPort      = var.container_port
        }
      ]
      environmentFiles : [
        {
          "value" : "arn:aws:s3:::${aws_s3_bucket.envBucket.bucket}/drugsEnvFile.env",
          "type" : "s3"
        }
      ]
    }
  ])
}

resource "aws_iam_role" "ecs_task_role" {
  name = "drugs-${var.region}-ecsTaskRole"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "ecs-task-role-policy-attachment-s3" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.bucket-read.arn
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment-s3" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.bucket-read.arn
}

resource "aws_iam_policy" "db" {
  name        = "${module.vpc.name}-${var.region}-task-policy-dynamodb"
  description = "Policy that allows access to DynamoDB"

  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
       {
           "Effect": "Allow",
           "Action": [
               "dynamodb:CreateTable",
               "dynamodb:UpdateTimeToLive",
               "dynamodb:PutItem",
               "dynamodb:DescribeTable",
               "dynamodb:ListTables",
               "dynamodb:DeleteItem",
               "dynamodb:GetItem",
               "dynamodb:Scan",
               "dynamodb:Query",
               "dynamodb:UpdateItem",
               "dynamodb:UpdateTable",
               "rds:*"
           ],
           "Resource": "*"
       }
   ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-task-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.db.arn
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${module.vpc.name}-${var.region}-ecsTaskExecutionRole"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_service" "telegram-service" {
  name            = "telegram"
  cluster         = aws_ecs_cluster.pet-place-cluster.id
  task_definition = aws_ecs_task_definition.telegram-task-definition.arn
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups  = [aws_security_group.https-fargate.id]
    assign_public_ip = true // true for now
  }
  desired_count = var.amount_of_tasks
}

resource "aws_ecs_task_definition" "telegram-task-definition" {
  family                   = "ecs-task-definition-telegram"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  memory                   = "512"
  cpu                      = "256"
  execution_role_arn       = aws_iam_role.ecs_task_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  container_definitions    = jsonencode([
    {
      name             = "telegram"
      image            = "058264238248.dkr.ecr.${var.region}.amazonaws.com/${aws_ecr_repository.telegram-repository.name}:latest"
      essential        = true
      logConfiguration = {
        logDriver = "awslogs",
        "options" : {
          "awslogs-create-group" : "true",
          "awslogs-group" : aws_cloudwatch_log_group.groupForEcs.id,
          "awslogs-region" : var.region,
          "awslogs-stream-prefix" : "awslogs-drugs",
        }
      },
      portMappings = [
        {
          protocol      = "tcp"
          containerPort = var.container_port
          hostPort      = var.container_port
        }
      ]
      environmentFiles : [
        {
          "value" : "arn:aws:s3:::${aws_s3_bucket.envBucket.bucket}/telegramEnvFile.env",
          "type" : "s3"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "pets-service" {
  name            = "pets"
  cluster         = aws_ecs_cluster.pet-place-cluster.id
  task_definition = aws_ecs_task_definition.pets-task-definition.arn
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups  = [aws_security_group.https-fargate.id]
    assign_public_ip = true // true for now
  }
  load_balancer {
    target_group_arn = "arn:aws:elasticloadbalancing:us-east-2:058264238248:targetgroup/sneaky-tg/bfd770111fed12b6"
    container_name   = "pets"
    container_port   = var.container_port
  }
  desired_count = var.amount_of_tasks
}

resource "aws_ecs_task_definition" "pets-task-definition" {
  family                   = "ecs-task-definition-pets"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  memory                   = "512"
  cpu                      = "256"
  execution_role_arn       = aws_iam_role.ecs_task_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  container_definitions    = jsonencode([
    {
      name             = "pets"
      image            = "058264238248.dkr.ecr.${var.region}.amazonaws.com/${aws_ecr_repository.pets-repository.name}:latest"
      essential        = true
      logConfiguration = {
        logDriver = "awslogs",
        "options" : {
          "awslogs-create-group" : "true",
          "awslogs-group" : aws_cloudwatch_log_group.groupForEcs.id,
          "awslogs-region" : var.region,
          "awslogs-stream-prefix" : "awslogs-drugs",
        }
      },
      portMappings = [
        {
          protocol      = "tcp"
          containerPort = var.container_port
          hostPort      = var.container_port
        }
      ]
      environmentFiles : [
        {
          "value" : "arn:aws:s3:::${aws_s3_bucket.envBucket.bucket}/drugsEnvFile.env",
          "type" : "s3"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "users-service" {
  name            = "users"
  cluster         = aws_ecs_cluster.pet-place-cluster.id
  task_definition = aws_ecs_task_definition.users-task-definition.arn
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups  = [aws_security_group.https-fargate.id]
    assign_public_ip = true // true for now
  }
  load_balancer {
    target_group_arn = aws_alb_target_group.users.id
    container_name   = "users"
    container_port   = var.container_port
  }
  desired_count = var.amount_of_tasks
}

resource "aws_ecs_task_definition" "users-task-definition" {
  family                   = "ecs-task-definition-users"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  memory                   = "512"
  cpu                      = "256"
  execution_role_arn       = aws_iam_role.ecs_task_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  container_definitions    = jsonencode([
    {
      name             = "users"
      image            = "058264238248.dkr.ecr.${var.region}.amazonaws.com/${aws_ecr_repository.users-repository.name}:latest"
      essential        = true
      logConfiguration = {
        logDriver = "awslogs",
        "options" : {
          "awslogs-create-group" : "true",
          "awslogs-group" : aws_cloudwatch_log_group.groupForEcs.id,
          "awslogs-region" : var.region,
          "awslogs-stream-prefix" : "awslogs-drugs",
        }
      },
      portMappings = [
        {
          protocol      = "tcp"
          containerPort = var.container_port
          hostPort      = var.container_port
        }
      ]
      environmentFiles : [
        {
          "value" : "arn:aws:s3:::${aws_s3_bucket.envBucket.bucket}/drugsEnvFile.env",
          "type" : "s3"
        }
      ]
    }
  ])
}
