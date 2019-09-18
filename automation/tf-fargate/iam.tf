
resource "aws_iam_role" "ecs_role" {
  name               = "mamip_ecs_role"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_service_assume_role_policy.json}"
}

data "aws_iam_policy_document" "ecs_service_policy" {
  statement {
    effect = "Allow"
    resources = [
        "arn:aws:s3:::mamip-artifacts/mamip",
        "arn:aws:s3:::mamip-artifacts/*"
    ]
    actions = [
        "s3:PutObject",
        "s3:GetObject"
    ]
  }
  statement {
    effect = "Allow"
    resources = ["*"]
    actions = [
        "iam:ListPolicies",
        "iam:GetPolicyVersion"
    ]
  }
}

data "aws_iam_policy_document" "ecs_service_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    
    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

/* ecs service scheduler role */
resource "aws_iam_role_policy" "ecs_service_role_policy" {
  name   = "ecs_service_role_policy"
  policy = "${data.aws_iam_policy_document.ecs_service_policy.json}"
  role   = "${aws_iam_role.ecs_role.id}"
}
