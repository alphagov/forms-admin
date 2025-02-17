locals {
  logs_stream_prefix = "${data.terraform_remote_state.review.outputs.review_apps_log_group_name}/pr-${var.pull_request_number}"

  review_app_hostname = "pr-${var.pull_request_number}.review.forms.service.gov.uk"

  forms_admin_startup_commands = [
    "rails db:prepare",
    "rails s -b 0.0.0.0"
  ]

  forms_admin_shell_script = join(" && ", local.forms_admin_startup_commands)

  forms_admin_env_vars = [
    { name = "DATABASE_URL", value = "postgres://postgres:postgres@127.0.0.1:5432" },
    { name = "GOVUK_APP_DOMAIN", value = "publishing.service.gov.uk" },
    { name = "PORT", value = "3000" },
    { name = "RAILS_DEVELOPMENT_HOSTS", value = "pr-${var.pull_request_number}.review.forms.service.gov.uk" },
    { name = "RAILS_ENV", value = "production" },
    { name = "SECRET_KEY_BASE", value = "unsecured_secret_key_material" },
    { name = "SETTINGS__ACT_AS_USER_ENABLED", value = "true" },
    { name = "SETTINGS__AUTH_PROVIDER", value = "developer" },
    { name = "SETTINGS__FORMS_API__AUTH_KEY", value = "unsecured_api_key_for_review_apps_only" },
    { name = "SETTINGS__FORMS_API__BASE_URL", value = "pr-${var.pull_request_number}.review.forms.service.gov.uk" },
    { name = "SETTINGS__FORMS_ENV", value = "review" },
    { name = "SETTINGS__FORMS_RUNNER__URL", value = "https://forms.service.gov.uk/" },
  ]

  forms_api_env_vars = [
    { name = "DATABASE_URL", value = "postgres://postgres:postgres@127.0.0.1:5432" },
    { name = "EMAIL", value = "review-app-submissions@review.forms.service.gov.uk" },
    { name = "RAILS_DEVELOPMENT_HOSTS", value = "pr-${var.pull_request_number}.review.forms.service.gov.uk" },
    { name = "RAILS_ENV", value = "production" },
    { name = "SECRET_KEY_BASE", value = "unsecured_secret_key_material" },
    { name = "SETTINGS__FORMS_API__AUTH_KEY", value = "unsecured_api_key_for_review_apps_only" },
    { name = "SETTINGS__FORMS_ENV", value = "review" },
  ]
}

resource "aws_ecs_task_definition" "task" {
  family = "forms-admin-pr-${var.pull_request_number}"

  network_mode = "awsvpc"
  cpu          = 256
  memory       = 1024

  requires_compatibilities = ["FARGATE"]

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  execution_role_arn = data.terraform_remote_state.review.outputs.ecs_task_execution_role_arn

  container_definitions = jsonencode([
    # forms-admin
    {
      name        = "forms-admin"
      image       = var.forms_admin_container_image
      command     = ["sh", "-c", local.forms_admin_shell_script]
      essential   = true
      environment = local.forms_admin_env_vars

      dockerLabels = {
        "traefik.http.routers.forms-admin-pr-${var.pull_request_number}.rule" : "Host(`${local.review_app_hostname}`)",
        "traefik.http.routers.forms-admin-pr-${var.pull_request_number}.service" : "forms-admin-pr-${var.pull_request_number}",
        "traefik.http.services.forms-admin-pr-${var.pull_request_number}.loadbalancer.server.port" : "3000",
        "traefik.http.services.forms-admin-pr-${var.pull_request_number}.loadbalancer.healthcheck.path" : "/up",
        "traefik.http.middlewares.forms-admin-pr-${var.pull_request_number}.basicauth.users": data.terraform_remote_state.review.outputs.traefik_basic_auth_credentials
        "traefik.enable" : "true",
      },

      portMappings = [
        {
          containerPort = 3000
          protocol      = "tcp"
          appProtocl    = "http"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = data.terraform_remote_state.review.outputs.review_apps_log_group_name
          awslogs-region        = "eu-west-2"
          awslogs-stream-prefix = "${local.logs_stream_prefix}/forms-admin"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "wget -O - 'http://localhost:3000/up' || exit 1"]
        interval    = 30
        retries     = 5
        startPeriod = 180
      }

      dependsOn = [
        {
          containerName = "postgres"
          condition     = "HEALTHY"
        }
      ]
    },

    # forms-api
    {
      name        = "forms-api"
      image       = "711966560482.dkr.ecr.eu-west-2.amazonaws.com/forms-api-deploy:latest"
      command     = []
      essential   = true
      environment = local.forms_api_env_vars

      portMappings = [{ containerPort = 9292 }]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = data.terraform_remote_state.review.outputs.review_apps_log_group_name
          awslogs-region        = "eu-west-2"
          awslogs-stream-prefix = "${local.logs_stream_prefix}/forms-api"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "wget -O - 'http://localhost:9292/up' || exit 1"]
        interval    = 30
        retries     = 5
        startPeriod = 180
      }

      dependsOn = [
        {
          containerName = "postgres"
          condition     = "HEALTHY"
        }
      ]
    },

    # postgres
    {
      name      = "postgres"
      image     = "public.ecr.aws/docker/library/postgres:13.12"
      command   = []
      essential = true

      portMappings = [{ containerPort = 5432 }]

      environment = [
        { name = "POSTGRES_PASSWORD", value = "postgres" }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = data.terraform_remote_state.review.outputs.review_apps_log_group_name
          awslogs-region        = "eu-west-2"
          awslogs-stream-prefix = "${local.logs_stream_prefix}/postgres"
        }
      }

      healthCheck = {
        command = ["CMD-SHELL", "psql -h localhost -p 5432 -U postgres -c \"SELECT current_timestamp - pg_postmaster_start_time();\""]
      }
    },

    # forms-api-seeding
    {
      name        = "forms-api-seeding"
      image       = "711966560482.dkr.ecr.eu-west-2.amazonaws.com/forms-api-deploy:latest"
      command     = ["rake", "db:setup"]
      essential   = false
      environment = local.forms_api_env_vars

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = data.terraform_remote_state.review.outputs.review_apps_log_group_name
          awslogs-region        = "eu-west-2"
          awslogs-stream-prefix = "${local.logs_stream_prefix}/forms-api-seeding"
        }
      }

      dependsOn = [
        {
          containerName = "postgres"
          condition     = "HEALTHY"
        }
      ]
    },
  ])
}
