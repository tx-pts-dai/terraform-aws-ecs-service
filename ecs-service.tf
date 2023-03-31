resource "aws_cloudwatch_log_group" "ecs_service" {
  name = var.name
  # Possible retention setting
  # [0 1 3 5 7 14 30 60 90 120 150 180 365 400 545 731 1827 3653]
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "ecs_service" {
  family                   = var.name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = aws_iam_role.this.arn
  task_role_arn            = aws_iam_role.this.arn
  container_definitions = jsonencode([
    {
      name      = var.name
      image     = var.image
      essential = true
      portMappings = [{
        protocol      = "tcp"
        containerPort = var.container_port
      }]
      linuxParameters = {
        initProcessEnabled = true
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_service.name
          awslogs-region        = "eu-west-1"
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
        # file_system_id          = aws_efs_file_system.fs.id
        file_system_id          = volume.value.fs_id
        root_directory          = volume.value.root
        transit_encryption      = "ENABLED"
        transit_encryption_port = 2999
        authorization_config {
          # access_point_id = aws_efs_access_point.test.id
          access_point_id = volume.value.access_point_id
          iam             = "ENABLED"
        }
      }
    }
  }

  tags = var.tags
}

resource "aws_ecs_service" "ecs_service" {
  name                   = var.name
  cluster                = var.cluster_id
  task_definition        = aws_ecs_task_definition.ecs_service.arn
  launch_type            = "FARGATE"
  scheduling_strategy    = "REPLICA"
  desired_count          = var.desired_replicas
  enable_execute_command = true

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
}
