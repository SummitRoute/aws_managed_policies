resource "aws_cloudwatch_event_rule" "cw_run_task" {
  name                = "run-mamip"
  description         = "Run Mamip every 6 hours"
  schedule_expression = "rate(6 hours)"
}

resource "aws_cloudwatch_event_target" "cw_event_target" {
  target_id = "mamip_target_terraform"
  arn = "${aws_ecs_cluster.ecs_cluster.arn}"
  rule = "${aws_cloudwatch_event_rule.cw_run_task.name}"
  role_arn = "arn:aws:iam::567589703415:role/ecsEventsRole"
  
  ecs_target {
      launch_type           = "FARGATE"
      platform_version      = "LATEST"
      task_definition_arn   = "${aws_ecs_task_definition.mamip_td.arn}"
      network_configuration {
        subnets             = ["subnet-0877cf6c"]
        security_groups     = ["sg-0f669a11a7a45c8dd"]
        assign_public_ip    = true
      }
  }
}