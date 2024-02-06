terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

variable "dbPassword" {
  description = "Password for the db"
}

variable "aws_profile" {
  default = "personal"
}

variable "domain" {
  default = "lnt.digital"
  description = "Bought and managed by Nacho, don't know how tf to transfer it"
}

variable "vpc_cidr" {
  default = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "amount_of_tasks" {
  default = 1
  description = "This is to set the amount of tasks you wish running, pro tip, set as 0 to not pay fargate"
}

variable "use_nat" {
  default = true
  description = "set to false to not pay that shit, also use in combination with fargate"
}

variable "region" {
  default = "us-east-2"
}

variable "container_port" {
  default = 9000
}

variable "envBucket" {
  default = "env"
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile
}

provider "aws" {
  alias = "virginia"
  region = "us-east-1"
  profile = var.aws_profile
}
