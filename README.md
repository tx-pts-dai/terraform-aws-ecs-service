# AWS ECS Service Terraform module

This Terraform module is meant to offer an easy interface to deploy a ECS Service/Task.

## Why do we need it?

The idea is to abstract away from the user certain complexity so that he can, just by specifying few parameters, deploy a working ECS Task while the module takes some opinionated decisions for him.

The module provides support for:

- Attaching to a Load Balancer target group (`lb_target_group_arn` parameter)
- Attaching EFS volumes (`efs_volumes` parameter)
- Executing SSM commands on the instance
- Outputting logs to a separate CloudWatch Log Group
- Passing secrets via SecretsManager

## Usage

Here's an example of how you can use the module by specifying the required parameters.

```tf
module "hello_world" {
  source     = "github.com/tx-pts-dai/terraform-aws-ecs-service?ref=v0.1.0"
  cluster_id = aws_ecs_cluster.my_cluster.id
  subnet_ids = [
    "subnet-abcdef12",
    "subnet-34567890",
  ]
  name             = "hello-world"
  image            = "ghcr.io/example/hello-world@latest"
  container_cpu    = 256
  container_memory = 512
  container_port   = 8080
  desired_replicas = 2
}
```

### Attach the service to a Load Balancer Target Group

Define your target group and then attach it via the `lb_target_group_arn` parameter.

```tf
# This example is for demonstrative purposes only.
resource "aws_lb_target_group" "hello_world" {
  name                 = "helloworld"
  port                 = 8080
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = vpc-012362ae3
}

module "hello_world" {
  ...
  lb_target_group_arn = aws_lb_target_group.hello_world.arn
}
```

### Attach an existing EFS volume

Using the `efs_volumes` parameter, you can attach as many EFS you want to the ECS service. They will be mounted inside the container at the specified `mounted_at` parameter.

```tf
resource "aws_efs_file_system" "hello_world" {}

module "hello_world" {
  ...
  efs_volumes = {
    workspace = {
      fs_id      = aws_efs_file_system.hello_world.id
      mounted_at = "/data/workspace"
    }
  }
}
```

## Live examples

- <https://github.com/tx-pts-dai/ness-nebula-app>
- <https://github.com/tx-pts-dai/ness-claro-statistic-app> (coming soon)

## Development

If you want to contribute to this module we recommend installing the pre-commit actions for formatting and validating your Terraform code. How?

1. [Install pre-commit](https://pre-commit.com/)
2. Execute `pre-commit install`. (This will generate pre-commit hooks according to the config in `.pre-commit-config.yaml`)
3. Before each commit, validation will happen automatically now (uninstall with `pre-commit uninstall`)

If you don't want this to run automatically you can trigger it yourself via: `pre-commit run -a`

The `pre-commit` command will run:

- Terraform fmt
- Terraform validate
- Terraform docs
- Terraform validate with tflint
- check for merge conflicts
- fix end of files

as described in the `.pre-commit-config.yaml` file

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_service.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_policy.execute_command](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.read_secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ecs_task_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.execute_command](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.read_secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.execute_command](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.read_secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | The ECS cluster ID where the task will be deployed to | `string` | n/a | yes |
| <a name="input_container_cpu"></a> [container\_cpu](#input\_container\_cpu) | The number of milli-cpu units reserved for each replica | `number` | n/a | yes |
| <a name="input_container_memory"></a> [container\_memory](#input\_container\_memory) | The amount (in MiB) of memory reserved for each replica | `number` | n/a | yes |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | Container port | `number` | n/a | yes |
| <a name="input_deployment_max_health"></a> [deployment\_max\_health](#input\_deployment\_max\_health) | Percentage of max healthy deployment | `number` | `100` | no |
| <a name="input_deployment_min_health"></a> [deployment\_min\_health](#input\_deployment\_min\_health) | Percentage of min healthy deployment. It's recommended to set it > 0 for highly available workloads. | `number` | `0` | no |
| <a name="input_desired_replicas"></a> [desired\_replicas](#input\_desired\_replicas) | Desired number of replicas | `number` | `1` | no |
| <a name="input_efs_volumes"></a> [efs\_volumes](#input\_efs\_volumes) | Map of EFS volumes to mount | <pre>map(object({<br>    fs_id           = string<br>    mounted_at      = string                # the directory to which the EFS volume will be mounted at<br>    mountable_root  = optional(string, "/") # the directory in the EFS volume to be mounted inside the container<br>    access_point_id = optional(string)<br>  }))</pre> | `{}` | no |
| <a name="input_env_vars"></a> [env\_vars](#input\_env\_vars) | Environment variables. Map is in the format 'ENV\_KEY' => 'ENV\_VALUE' | `map(string)` | `{}` | no |
| <a name="input_health_startup_delay_seconds"></a> [health\_startup\_delay\_seconds](#input\_health\_startup\_delay\_seconds) | Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown. Only valid for LB-exposed services. | `number` | `180` | no |
| <a name="input_image"></a> [image](#input\_image) | Container image to be deployed. | `string` | n/a | yes |
| <a name="input_lb_target_group_arn"></a> [lb\_target\_group\_arn](#input\_lb\_target\_group\_arn) | Load Balancer's Target Group ARN to attach to this service. Don't provide it if it doesn't need to be accessed from outside | `string` | `null` | no |
| <a name="input_log_retention_in_days"></a> [log\_retention\_in\_days](#input\_log\_retention\_in\_days) | How long to keep container logs in CloudWatch (0 1 3 5 7 14 30 60 90 120 150 180 365 400 545 731 1827 3653) | `number` | `7` | no |
| <a name="input_name"></a> [name](#input\_name) | The ECS service name | `string` | n/a | yes |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | Secret Environment variables. Map is in the format 'ENV\_KEY' => 'SECRET\_ARN' | `map(string)` | `{}` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | Security groups to be attached to the task | `list(string)` | `[]` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnets where the task will be run in. Most of the times you want to use your private ones. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags for the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | ARN of the created ECS IAM role used to execute the task |
| <a name="output_task_definition_arn"></a> [task\_definition\_arn](#output\_task\_definition\_arn) | ARN of the created ECS task definition |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained by [Alfredo Gottardo](https://github.com/AlfGot), [David Beauverd](https://github.com/Davidoutz), [Davide Cammarata](https://github.com/DCamma), [Demetrio Carrara](https://github.com/sgametrio) and [Roland Bapst](https://github.com/rbapst-tamedia)

## License

Apache 2 Licensed. See [LICENSE](< link to license file >) for full details.
