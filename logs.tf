resource "aws_cloudwatch_log_group" "groupForEcs" {
  name              = "/aws/ecs/cloudwatch"
  retention_in_days = 3
}
