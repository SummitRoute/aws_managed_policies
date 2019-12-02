variable "aws_region" {
  default = "eu-west-1"
  description = "AWS Region"
}

variable "env" {
  default     = "dev"
  description = "Environment"
}

variable "project" {
  default     = "no-project-name"
  description = "Project Name"
}

variable "description" {
  default     = "empty-project-description"
  description = "Project Description"
}

variable "artifacts_bucket" {
  default     = "no-artifact-bucket-defined"
  description = "Artifacts Bucket Name"
}

variable "ecs_event_role" {
  default     = "arn:aws:iam::567589703415:role/ecsEventsRole"
  description = "IAM Role used for CloudWatch"
}

variable "ecs_taskexec_role" {
  default     = "arn:aws:iam::567589703415:role/ecsTaskExecutionRole"
  description = "IAM Role used for Task Execution"
}

variable "subnets" {
  type        = list(string)
  default     = ["subnet-0877cf6c"]
  description = "Subnets used for Fargate Containers"
}

variable "security_groups" {
  type        = list(string)
  default     = ["sg-0f669a11a7a45c8dd"]
  description = "Security Groups used for Fargate"
}

variable "schedule" {
  default     = "rate(6 hours)"
  description = "Schedule for your job"
}

variable "assign_public_ip" {
  default     = "false"
  description = "Set public IP on Fargate Container"
}

variable "ecs_cpu_units" {
  default     = "1024"
  description = "Container: Number of CPU Units"
}

variable "ecs_memory" {
  default     = "2048"
  description = "Container: Memory in MB"
}