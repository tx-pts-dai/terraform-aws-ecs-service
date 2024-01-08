data "aws_region" "current" {}

moved {
  from = aws_cloudwatch_log_group.ecs_service
  to   = aws_cloudwatch_log_group.this
}

resource "aws_cloudwatch_log_group" "this" {
  name = var.name
  # Possible retention setting
  # [0 1 3 5 7 14 30 60 90 120 150 180 365 400 545 731 1827 3653]
  retention_in_days = var.log_retention_in_days
}

moved {
  from = aws_ecs_task_definition.ecs_service
  to   = aws_ecs_task_definition.this
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = aws_iam_role.this.arn
  task_role_arn            = aws_iam_role.this.arn
  container_definitions = jsonencode([
    {
      name        = var.name
      image       = var.image
      essential   = true
      stopTimeout = var.stop_timeout
      portMappings = [{
        protocol      = "tcp"
        containerPort = var.container_port
      }]
      mountPoints = [for name, volume in var.efs_volumes : {
        containerPath = volume.mounted_at
        sourceVolume  = name
      }]
      linuxParameters = {
        initProcessEnabled = true
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "ecs"
        }
      }
      secrets     = [for name, valueFrom in var.secrets : { name : name, valueFrom : valueFrom }]
      environment = [for name, value in var.env_vars : { name : name, value : value }]
    }
  ])

  dynamic "volume" {
    for_each = var.efs_volumes
    content {
      name = volume.key

      efs_volume_configuration {
        file_system_id     = volume.value.fs_id
        root_directory     = volume.value.mountable_root
        transit_encryption = "ENABLED"
      }
    }
  }

  tags = var.tags
}


moved {
  from = aws_ecs_service.ecs_service
  to   = aws_ecs_service.this
}

resource "aws_ecs_service" "this" {
  name                   = var.name
  cluster                = var.cluster_id
  task_definition        = aws_ecs_task_definition.this.arn
  launch_type            = "FARGATE"
  scheduling_strategy    = "REPLICA"
  desired_count          = var.desired_replicas
  enable_execute_command = true
  wait_for_steady_state  = true

  dynamic "deployment_circuit_breaker" {
    for_each = (var.deployment_circuit_breaker != null) ? [var.deployment_circuit_breaker] : []

    content {
      enable   = deployment_circuit_breaker.value.enable
      rollback = deployment_circuit_breaker.value.rollback
    }
  }

  health_check_grace_period_seconds = (var.lb_target_group_arn != null) ? var.health_startup_delay_seconds : null

  deployment_maximum_percent         = var.deployment_max_health
  deployment_minimum_healthy_percent = var.deployment_min_health

  # Ignore changes since count attribute is handled
  # by autoscaling policy
  lifecycle {
    ignore_changes = [desired_count]
  }

  network_configuration {
    security_groups = var.security_groups
    subnets         = var.subnet_ids
  }

  dynamic "load_balancer" {
    for_each = (var.lb_target_group_arn != null) ? [1] : []

    content {
      target_group_arn = var.lb_target_group_arn
      container_name   = var.name
      container_port   = var.container_port
    }
  }

  tags = var.tags

  dynamic "timeouts" {
    for_each = (var.provider_timeouts != null) ? [var.provider_timeouts] : []

    content {
      create = timeouts.value.create
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}
