variable "cluster_id" {
  description = "The ECS cluster ID where the task will be deployed to"
  type        = string
}

variable "name" {
  description = "The ECS service name"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets where the task will be run in. Most of the times you want to use your private ones."
  type        = list(string)
}

variable "image" {
  description = "Container image to be deployed."
  type        = string
}

variable "container_cpu" {
  description = "The number of milli-cpu units reserved for each replica"
  type        = number
}

variable "container_memory" {
  description = "The amount (in MiB) of memory reserved for each replica"
  type        = number
}

variable "container_port" {
  description = "Container port"
  type        = number
}

variable "desired_replicas" {
  description = "Desired number of replicas"
  type        = number
  default     = 1
}

variable "log_retention_in_days" {
  description = "How long to keep container logs in CloudWatch (0 1 3 5 7 14 30 60 90 120 150 180 365 400 545 731 1827 3653)"
  type        = number
  default     = 7
  validation {
    condition     = contains([0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_in_days)
    error_message = "The retention must be in the [0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653] range"
  }
}

variable "deployment_min_health" {
  description = "Percentage of min healthy deployment. It's recommended to set it > 0 for highly available workloads."
  type        = number
  default     = 0
}

variable "deployment_max_health" {
  description = "Percentage of max healthy deployment"
  type        = number
  default     = 100
}

variable "security_groups" {
  description = "Security groups to be attached to the task"
  type        = list(string)
  default     = []
}

variable "lb_target_group_arn" {
  description = "Load Balancer's Target Group ARN to attach to this service. Don't provide it if it doesn't need to be accessed from outside"
  type        = string
  default     = null
}


variable "env_vars" {
  description = "Environment variables. Map is in the format 'ENV_KEY' => 'ENV_VALUE'"
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Secret Environment variables. Map is in the format 'ENV_KEY' => 'SECRET_ARN'"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "The tags for the resources"
  type        = map(string)
  default     = {}
}

variable "health_startup_delay_seconds" {
  description = "Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown. Only valid for LB-exposed services."
  type        = number
  default     = 3 * 60
}

variable "efs_volumes" {
  description = "Map of EFS volumes to mount"
  type = map(object({
    fs_id           = string
    mounted_at      = string                # the directory to which the EFS volume will be mounted at
    mountable_root  = optional(string, "/") # the directory in the EFS volume to be mounted inside the container
    access_point_id = optional(string)
  }))
  default = {}
}

variable "extra_iam_policies" {
  description = "Map of IAM policy ARNs to be attached to the IAM role impersonated by the ECS Task. (e.g. 's3_access' => aws_iam_policy.s3_access.arn)"
  type        = map(string)
  default     = {}
}

variable "stop_timeout" {
  description = "Seconds to wait before force killing a container"
  type        = number
  validation {
    condition     = var.stop_timeout >= 0 && var.stop_timeout <= 120
    error_message = "value should be between 0 and 120"
  }
  default = 30
}


variable "deployment_circuit_breaker" {
  description = "(Optional) Configuration block for deployment circuit breaker"
  type = object({
    enable   = optional(bool, true)
    rollback = optional(bool, true)
  })
  default = {}
}

variable "provider_timeouts" {
  description = "Create, update, and delete timeouts for the provider (if operation takes longer, terraform will fail)"
  type = object({
    create = optional(string, "5m")
    update = optional(string, "5m")
    delete = optional(string, "5m")
  })
  default = {}
}
