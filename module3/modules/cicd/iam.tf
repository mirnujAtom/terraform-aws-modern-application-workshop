data "aws_iam_policy_document" "artifacts_s3_iam_policy_document" {
  statement {
    sid = "WhitelistedGet"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning"
    ]
    resources = [
      "${aws_s3_bucket.artfacts_s3_bucket.arn}",
      "${aws_s3_bucket.artfacts_s3_bucket.arn}/*"
    ]
    principals {
      type = "AWS"
      identifiers = [
        "${aws_iam_role.application-service-code-build-service-role.arn}",
        "${aws_iam_role.application-service-code-pipeline-service-role.arn}"
      ]
    }

  }
  statement {
    sid = "WhitelistedPut"
    effect = "Allow"
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.artfacts_s3_bucket.arn}",
      "${aws_s3_bucket.artfacts_s3_bucket.arn}/*"
    ]
    principals {
      type = "AWS"
      identifiers = [
        "${aws_iam_role.application-service-code-build-service-role.arn}",
        "${aws_iam_role.application-service-code-pipeline-service-role.arn}"
      ]
    }
  }
}


//////////////////////////////////////////////////////////


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


///////////////////////////////////////////////////////////////////////



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


/////////////////////////

data "aws_iam_policy_document" "application-codepipeline-ecr-policy-document" {
  statement {
    sid = "allow-push-pull-ecr"
    effect = "Allow"
    principals {
      identifiers = [ "${aws_iam_role.application-service-code-build-service-role.arn}" ]
      type = "AWS"
    }
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload"
    ]
  }
}

/////////////////////

resource "aws_ecr_repository_policy" "cicd-ecr-policy" {
  policy = "${data.aws_iam_policy_document.application-codepipeline-ecr-policy-document.json}"
  repository = "${var.ecr_repo_name}"
}