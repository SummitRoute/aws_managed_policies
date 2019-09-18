
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.env}-ecs-cluster"
}

data "template_file" "mamip_task" {
  template = "${file("./automation/tf-fargate/tasks/task_definition.json")}"
}

resource "aws_ecs_task_definition" "mamip_td" {
  family                   = "mamip_task_definition_${var.env}"
  container_definitions    = "${data.template_file.mamip_task.rendered}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = "${aws_iam_role.ecs_role.arn}"
  task_role_arn            = "${aws_iam_role.ecs_role.arn}"
}

