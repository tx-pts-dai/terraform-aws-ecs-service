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
    root            = string
    access_point_id = string
  }))
}
