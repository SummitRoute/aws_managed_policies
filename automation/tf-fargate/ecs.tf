
resource "aws_ecs_cluster" "ecs_cluster" {
  name               = "${var.project}_ecs_cluster_${var.env}"
  capacity_providers = ["FARGATE_SPOT"]
  
  setting {
      name  = "containerInsights"
      value = "enabled"
  }

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = "100"
  }
  
  tags = {
    Project     = "${var.project}"
    Environment = "${var.env}"
  }
}

data "template_file" "mamip_task" {
  template = "${file("./automation/tf-fargate/tasks/task_definition.tpl")}"
  vars = {
    container_image  = "${var.container_image}"
    project          = "${var.project}"
    aws_region       = "${var.aws_region}"
  }
}

resource "aws_ecs_task_definition" "mamip_td" {
  family                   = "${var.project}_task_definition_${var.env}"
  container_definitions    = "${data.template_file.mamip_task.rendered}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "${var.ecs_cpu_units}"
  memory                   = "${var.ecs_memory}"
  execution_role_arn       = "${var.ecs_taskexec_role}"
  task_role_arn            = "${aws_iam_role.ecs_role.arn}"
  
  tags = {
    Project     = "${var.project}"
    Environment = "${var.env}"
  }
}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/ecs/${var.project}"
  retention_in_days = "${var.log_group_retention}"

  tags = {
    Project     = "${var.project}"
    Environment = "${var.env}"
  }
}
