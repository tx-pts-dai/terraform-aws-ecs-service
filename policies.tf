# Allow task execution - required
moved {
  from = aws_iam_role.ecs_task_execution
  to   = aws_iam_role.this
}

resource "aws_iam_role" "this" {
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = var.tags
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    sid    = ""

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Allow logging to CloudWatch
data "aws_iam_policy_document" "logs" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_policy" "logs" {
  name   = "${var.name}-logs"
  policy = data.aws_iam_policy_document.logs.json
}

resource "aws_iam_role_policy_attachment" "logs" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.logs.arn
}

# Allow reading secrets from SecretsManager
data "aws_iam_policy_document" "read_secrets" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = values(var.secrets)
  }
}

resource "aws_iam_policy" "read_secrets" {
  count  = length(var.secrets) > 0 ? 1 : 0
  name   = "${var.name}-read-secrets"
  policy = data.aws_iam_policy_document.read_secrets.json
}

resource "aws_iam_role_policy_attachment" "read_secrets" {
  count      = length(var.secrets) > 0 ? 1 : 0
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.read_secrets[0].arn
}


# Allow executing SSM commands
data "aws_iam_policy_document" "execute_command" {
  statement {
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "execute_command" {
  name   = "${var.name}-execute-command"
  policy = data.aws_iam_policy_document.execute_command.json
}

resource "aws_iam_role_policy_attachment" "execute_command" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.execute_command.arn
}

# Custom policies passed to module through variables
resource "aws_iam_role_policy_attachment" "extra" {
  for_each   = { for v, k in var.extra_iam_policies : v => k }
  role       = aws_iam_role.this.name
  policy_arn = each.value
}
