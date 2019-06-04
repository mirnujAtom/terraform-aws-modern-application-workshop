
resource "aws_iam_role" "EcsServiceRole" {
  name = "EcsServiceRole"
  assume_role_policy = "${data.aws_iam_policy_document.EcsServiceRole-assume.json}"
}

data "aws_iam_policy_document" "EcsServiceRole-assume" {
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
  name = "ecs-service-policy"
  policy = "${data.aws_iam_policy_document.ecs-service.json}"
}

resource "aws_iam_role_policy_attachment" "ecs-service-policy-attachment" {
  policy_arn = "${aws_iam_policy.ecs-service-policy.arn}"
  role = "${aws_iam_role.EcsServiceRole.name}"
}

//////////////////

resource "aws_iam_role" "ECSTaskRole" {
  name = "ECSTaskRole"
  assume_role_policy = "${data.aws_iam_policy_document.ECSTaskRole-assume.json}"
}

data "aws_iam_policy_document" "ECSTaskRole-assume" {
  statement {
    effect = "Allow"
    actions = [ "sts:AssumeRole" ]
    principals {
      identifiers = [ "ecs-tasks.amazonaws.com" ]
      type = "Service"
    }
  }
}


data "aws_iam_policy_document" "AmazonECSTaskRolePolicy-document" {
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
    resources = [ "arn:aws:dynamodb:*:*:table/MysfitsTable*" ]
  }
}

resource "aws_iam_policy" "AmazonECSTaskRolePolicy" {
  name = "AmazonECSTaskRolePolicy"
  policy = "${data.aws_iam_policy_document.AmazonECSTaskRolePolicy-document.json}"
}

resource "aws_iam_role_policy_attachment" "AmazonECSTaskRolePolicy-attachment" {
  policy_arn = "${aws_iam_policy.AmazonECSTaskRolePolicy.arn}"
  role = "${aws_iam_role.ECSTaskRole.name}"
}



//////////////////////////////////////////////////////////////////////////////////////



resource "aws_iam_role" "MythicalMysfitsServiceCodePipelineServiceRole" {
  name = "MythicalMysfitsServiceCodePipelineServiceRole"
  assume_role_policy = "${data.aws_iam_policy_document.MythicalMysfitsServiceCodePipelineServiceRole-assume.json}"
}

data "aws_iam_policy_document" "MythicalMysfitsServiceCodePipelineServiceRole-assume" {
  statement {
    effect = "Allow"
    actions = [ "sts:AssumeRole" ]
    principals {
      identifiers = [ "codepipeline.amazonaws.com" ]
      type = "Service"
    }
  }
}


data "aws_iam_policy_document" "MythicalMysfitsService-codepipeline-service-policy-document" {
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

resource "aws_iam_policy" "MythicalMysfitsService-codepipeline-service-policy" {
  name = "MythicalMysfitsService-codepipeline-service-policy"
  policy = "${data.aws_iam_policy_document.MythicalMysfitsService-codepipeline-service-policy-document.json}"
}

resource "aws_iam_role_policy_attachment" "MythicalMysfitsService-codepipeline-service-policy-role-attachment" {
  policy_arn = "${aws_iam_policy.MythicalMysfitsService-codepipeline-service-policy.arn}"
  role = "${aws_iam_role.MythicalMysfitsServiceCodePipelineServiceRole.name}"
}


///////////////////////////////////////



resource "aws_iam_role" "MythicalMysfitsServiceCodeBuildServiceRole" {
  name = "MythicalMysfitsServiceCodeBuildServiceRole"
  assume_role_policy = "${data.aws_iam_policy_document.MythicalMysfitsServiceCodeBuildServiceRole-assume.json}"
}

data "aws_iam_policy_document" "MythicalMysfitsServiceCodeBuildServiceRole-assume" {
  statement {
    effect = "Allow"
    actions = [ "sts:AssumeRole" ]
    principals {
      identifiers = [ "codebuild.amazonaws.com" ]
      type = "Service"
    }
  }
}


data "aws_iam_policy_document" "MythicalMysfitsService-CodeBuildServicePolicy-document" {
  statement {
    effect = "Allow"
    actions = [
      "codecommit:ListBranches",
      "codecommit:ListRepositories",
      "codecommit:BatchGetRepositories",
      "codecommit:Get*",
      "codecommit:GitPull"
    ]

    resources = ["arn:aws:codecommit:${var.region}:${var.account_id}:MythicalMysfitsServiceRepository"]
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

resource "aws_iam_policy" "MythicalMysfitsService-CodeBuildServicePolicy" {
  name = "MythicalMysfitsService-CodeBuildServicePolicy"
  policy = "${data.aws_iam_policy_document.MythicalMysfitsService-CodeBuildServicePolicy-document.json}"
}

resource "aws_iam_role_policy_attachment" "MythicalMysfitsServiceCodeBuildServiceRole-attachment" {
  policy_arn = "${aws_iam_policy.MythicalMysfitsService-CodeBuildServicePolicy.arn}"
  role = "${aws_iam_role.MythicalMysfitsServiceCodeBuildServiceRole.name}"
}

