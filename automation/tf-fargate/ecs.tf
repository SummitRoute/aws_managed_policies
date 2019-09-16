
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.environment}-ecs-cluster"
}

data "template_file" "mamip_task" {
  template = "${file("./tasks/task_definition.json")}"

  vars {
    image           = "${aws_ecr_repository.openjobs_app.repository_url}"
    secret_key_base = "${var.secret_key_base}"
  }
}

resource "aws_ecs_task_definition" "web" {
  family                   = "${var.environment}_mamip"
  container_definitions    = "${data.template_file.mamip_task.rendered}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = "${aws_iam_role.ecs_execution_role.arn}"
  task_role_arn            = "${aws_iam_role.ecs_execution_role.arn}"
}

