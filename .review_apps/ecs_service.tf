resource "aws_ecs_service" "app" {
  #checkov:skip=CKV_AWS_332:We don't want to target "LATEST" and get a surprise when a new version is released.
  name = "forms-admin-pr-${var.pull_request_number}"

  cluster         = data.terraform_remote_state.review.outputs.ecs_cluster_id
  task_definition = aws_ecs_task_definition.task.arn

  desired_count                      = 1
  deployment_maximum_percent         = "200"
  deployment_minimum_healthy_percent = "100"
  force_new_deployment               = true


  launch_type      = "FARGATE"
  platform_version = "1.4.0"

  network_configuration {
    subnets          = data.terraform_remote_state.review.outputs.private_subnet_ids
    security_groups  = [data.terraform_remote_state.review.outputs.review_apps_security_group_id]
    assign_public_ip = false
  }

  depends_on = [aws_ecs_task_definition.task]
}
