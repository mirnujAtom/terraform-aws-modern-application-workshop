
resource "aws_iam_role" "ecs-service-role" {
  name = "${var.app_name}-${var.environment}-ecs-service-role"
  assume_role_policy = "${data.aws_iam_policy_document.ecs-service-role-assume.json}"
}

data "aws_iam_policy_document" "ecs-service-role-assume" {
  statement {
    effect = "Allow"
    actions = [ "sts:AssumeRole" ]
    principals {
      identifiers = [ "ecs.amazonaws.com", "ecs-tasks.amazonaws.com" ]
      type = "Service"
    }
  }
}


data "aws_iam_policy_document" "ecs-service" {
  statement {
    effect = "Allow"
    actions = [ "ec2:AttachNetworkInterface",
                "ec2:CreateNetworkInterface",
                "ec2:CreateNetworkInterfacePermission",
                "ec2:DeleteNetworkInterface",
                "ec2:DeleteNetworkInterfacePermission",
      "ec2:Describe*",
      "ec2:DetachNetworkInterface",

      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:Describe*",
      "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
      "elasticloadbalancing:RegisterTargets",

      "iam:PassRole",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",


      "logs:DescribeLogStreams",
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents"

    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecs-service-policy" {
  name = "${var.app_name}-${var.environment}-ecs-service-policy"
  policy = "${data.aws_iam_policy_document.ecs-service.json}"
}

resource "aws_iam_role_policy_attachment" "ecs-service-policy-attachment" {
  policy_arn = "${aws_iam_policy.ecs-service-policy.arn}"
  role = "${aws_iam_role.ecs-service-role.name}"
}

//////////////////

resource "aws_iam_role" "ecs-task-role" {
  name = "${var.app_name}-${var.environment}-ecs-task-role"
  assume_role_policy = "${data.aws_iam_policy_document.ecs-task-role-assume.json}"
}

data "aws_iam_policy_document" "ecs-task-role-assume" {
  statement {
    effect = "Allow"
    actions = [ "sts:AssumeRole" ]
    principals {
      identifiers = [ "ecs-tasks.amazonaws.com" ]
      type = "Service"
    }
  }
}


data "aws_iam_policy_document" "ecs-task-role-policy-document" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",

      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents"

    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [ "dynamodb:Scan",
      "dynamodb:Query",
      "dynamodb:UpdateItem",
      "dynamodb:GetItem"
    ]
    resources = [ "arn:aws:dynamodb:*:*:table/${var.app_name}-${var.environment}-table*" ]
  }
}

resource "aws_iam_policy" "ecs-task-role-policy" {
  name = "${var.app_name}-${var.environment}-ecs-task-role-policy"
  policy = "${data.aws_iam_policy_document.ecs-task-role-policy-document.json}"
}

resource "aws_iam_role_policy_attachment" "ecs-task-role-policy-attachment" {
  policy_arn = "${aws_iam_policy.ecs-task-role-policy.arn}"
  role = "${aws_iam_role.ecs-task-role.name}"
}



//////////////////////////////////////////////////////////////////////////////////////



resource "aws_iam_role" "application-service-code-pipeline-service-role" {
  name = "${var.app_name}-${var.environment}-service-code-pipeline-service-role"
  assume_role_policy = "${data.aws_iam_policy_document.application-service-code-pipeline-service-role-assume.json}"
}

data "aws_iam_policy_document" "application-service-code-pipeline-service-role-assume" {
  statement {
    effect = "Allow"
    actions = [ "sts:AssumeRole" ]
    principals {
      identifiers = [ "codepipeline.amazonaws.com" ]
      type = "Service"
    }
  }
}


data "aws_iam_policy_document" "application-service-codepipeline-service-policy-document" {
  statement {
    effect = "Allow"
    actions = [
       "codecommit:GetBranch",
       "codecommit:GetCommit",
       "codecommit:UploadArchive",
       "codecommit:GetUploadArchiveStatus",
       "codecommit:CancelUploadArchive"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning"
    ]
    resources = [ "*" ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject"
    ]
    resources = [ "arn:aws:s3:::*" ]
  }
  statement {
    effect = "Allow"
    actions = [
      "elasticloadbalancing:*",
      "autoscaling:*",
      "cloudwatch:*",
      "ecs:*",
      "codebuild:*",
      "iam:PassRole"
    ]
    resources = [ "*" ]
  }
}

resource "aws_iam_policy" "application-service-codepipeline-service-policy" {
  name = "${var.app_name}-${var.environment}-service-codepipeline-service-policy"
  policy = "${data.aws_iam_policy_document.application-service-codepipeline-service-policy-document.json}"
}

resource "aws_iam_role_policy_attachment" "application-service-codepipeline-service-policy-role-attachment" {
  policy_arn = "${aws_iam_policy.application-service-codepipeline-service-policy.arn}"
  role = "${aws_iam_role.application-service-code-pipeline-service-role.name}"
}


///////////////////////////////////////



resource "aws_iam_role" "application-service-code-build-service-role" {
  name = "${var.app_name}-${var.environment}-service-code-build-service-role"
  assume_role_policy = "${data.aws_iam_policy_document.application-service-code-build-service-role-assume.json}"
}

data "aws_iam_policy_document" "application-service-code-build-service-role-assume" {
  statement {
    effect = "Allow"
    actions = [ "sts:AssumeRole" ]
    principals {
      identifiers = [ "codebuild.amazonaws.com" ]
      type = "Service"
    }
  }
}


data "aws_iam_policy_document" "application-service-code-build-service-policy-document" {
  statement {
    effect = "Allow"
    actions = [
      "codecommit:ListBranches",
      "codecommit:ListRepositories",
      "codecommit:BatchGetRepositories",
      "codecommit:Get*",
      "codecommit:GitPull"
    ]

    resources = ["arn:aws:codecommit:${var.region}:${var.account_id}:${var.app_name}-${var.environment}-service-repository"]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:GetObjectVersion",
      "s3:ListBucket"
    ]
    resources = [ "*" ]
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [ "*" ]
  }
  statement {
    effect = "Allow"
    actions = [
      "ecr:InitiateLayerUpload",
      "ecr:GetAuthorizationToken"
    ]
    resources = [ "*" ]
  }
}

resource "aws_iam_policy" "application-service-code-build-service-policy" {
  name = "${var.app_name}-${var.environment}-service-code-build-service-policy"
  policy = "${data.aws_iam_policy_document.application-service-code-build-service-policy-document.json}"
}

resource "aws_iam_role_policy_attachment" "application-service-code-build-service-role-attachment" {
  policy_arn = "${aws_iam_policy.application-service-code-build-service-policy.arn}"
  role = "${aws_iam_role.application-service-code-build-service-role.name}"
}

