locals {
  logs_stream_prefix = "${data.terraform_remote_state.review.outputs.review_apps_log_group_name}/pr-${var.pull_request_number}"
}
resource "aws_ecs_task_definition" "task" {
  family = "forms-admin-pr-${var.pull_request_number}"

  network_mode = "awsvpc"
  cpu          = 256
  memory       = 512

  requires_compatibilities = ["FARGATE"]

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  execution_role_arn = data.terraform_remote_state.review.outputs.ecs_task_execution_role_arn

  container_definitions = jsonencode([
    # forms-admin
    {
      name      = "forms-admin"
      image     = var.forms_admin_container_image
      command = []
      essential = true

      dockerLabels = {
        "traefik.http.routers.http.rule" : "Host(`pr-${var.pull_request_number}.review.forms.service.gov.uk`)",
        "traefik.enable" : "true"
      },

      readonlyRootFilesystem = true

      portMappings = [{ containerPort = 3000 }]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = data.terraform_remote_state.review.outputs.review_apps_log_group_name
          awslogs-region        = "eu-west-2"
          awslogs-stream-prefix = "${local.logs_stream_prefix}/forms-admin"
        }
      }
    },

    # forms-api
    {
      name      = "forms-api"
      image     = ""
      command = []
      essential = true

      readonlyRootFilesystem = true

      portMappings = [{ containerPort = 9292 }]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = data.terraform_remote_state.review.outputs.review_apps_log_group_name
          awslogs-region        = "eu-west-2"
          awslogs-stream-prefix = "${local.logs_stream_prefix}/forms-api"
        }
      }
    },

    # postgres
    {
      name      = "postgres"
      image     = "postgres:13.12"
      command = []
      essential = true

      readonlyRootFilesystem = true

      portMappings = [{ containerPort = 5432 }]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = data.terraform_remote_state.review.outputs.review_apps_log_group_name
          awslogs-region        = "eu-west-2"
          awslogs-stream-prefix = "${local.logs_stream_prefix}/postgres"
        }
      }
    },


    # forms-admin-seeding
    {
      # ...
      dependsOn = [
        {
          containerName = "postgres"
          condition     = "HEALTHY"
        }
      ]
    },

    # forms-api-seeding
    {
      # ...
      dependsOn = [
        {
          containerName = "postgres"
          condition     = "HEALTHY"
        }
      ]
    }
  ])
}
