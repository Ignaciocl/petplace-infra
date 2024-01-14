terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
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
