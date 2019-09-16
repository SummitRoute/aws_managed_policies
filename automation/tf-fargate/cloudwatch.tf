resource "aws_cloudwatch_event_rule" "run_task" {
  name                = "Run-Mamip"
  description         = "Run Mamip every 6 hours"
  schedule_expression = "cron(0 */6 * * ? *)"
  ecs_target  {
      launch_type           = "FARGATE"
      task_definition_arn   = "${aws_ecs_task_definition.task_name.arn}"
  }
  network_configuration  {
      subnets   = 
      task_definition_arn = ""
  }
}