resource "aws_appautoscaling_target" "review_app" {
  service_namespace  = "ecs"
  resource_id        = "service/${data.terraform_remote_state.review.outputs.ecs_cluster_id}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  max_capacity = 1
  min_capacity = 1
}

resource "aws_appautoscaling_scheduled_action" "shutdown_at_night" {
  name = "pr-${var.pull_request_number}-shutdown-at-night"

  service_namespace  = aws_appautoscaling_target.review_app.service_namespace
  resource_id        = aws_appautoscaling_target.review_app.resource_id
  scalable_dimension = aws_appautoscaling_target.review_app.scalable_dimension

  schedule = "cron(0 18 * * ? *)" # daily at 1800

  scalable_target_action {
    min_capacity = 0
    max_capacity = 0
  }
}

resource "aws_appautoscaling_scheduled_action" "startup_weekday_mornings" {
  name = "pr-${var.pull_request_number}-startup-weekday-mornings"

  service_namespace  = aws_appautoscaling_target.review_app.service_namespace
  resource_id        = aws_appautoscaling_target.review_app.resource_id
  scalable_dimension = aws_appautoscaling_target.review_app.scalable_dimension

  schedule = "cron(0 8 ? * MON-FRI *)" # Monday-Friday at 0800

  scalable_target_action {
    min_capacity = 1
    max_capacity = 1
  }
}
