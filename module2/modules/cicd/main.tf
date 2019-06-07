resource "aws_s3_bucket" "artfacts_s3_bucket" {
  bucket = "${var.app_name}-${var.environment}-artifacts-bucket"
  force_destroy = true

}

resource "aws_s3_bucket_policy" "site_s3_bucket_policy" {
  bucket = "${aws_s3_bucket.artfacts_s3_bucket.id}"
  policy = "${data.aws_iam_policy_document.artifacts_s3_iam_policy_document.json}"
}


resource "aws_codecommit_repository" "application-codecommit-repo" {
  repository_name = "${var.app_name}-${var.environment}-codecommit-repo"
}


resource "aws_codebuild_project" "application-codebuild-project" {
  name = "${var.app_name}-${var.environment}-codebuild-project"
  service_role = "${aws_iam_role.application-service-code-build-service-role.arn}"
  "artifacts" {
    type = "NO_ARTIFACTS"
  }
  "environment" {
    compute_type = "BUILD_GENERAL1_SMALL"
    privileged_mode = true
    environment_variable {
      name = "AWS_ACCOUNT_ID"
      value = "${var.account_id}"
    }
    environment_variable {
      name = "IMAGE_REPO"
      value = "${var.app_name}-${var.environment}"
    }
    environment_variable {
      name = "AWS_DEFAULT_REGION"
      value = "${var.region}"
    }
    image = "aws/codebuild/golang:1.11"
    type = "LINUX_CONTAINER"
  }

  "source" {
    type = "CODECOMMIT"
    location = "${aws_codecommit_repository.application-codecommit-repo.repository_id}"
  }
}

resource "aws_codepipeline" "application-codepipeline" {
  name = "${var.app_name}-${var.environment}-pipeline"
  role_arn = "${aws_iam_role.application-service-code-pipeline-service-role.arn}"
  "artifact_store" {
    location = "${aws_s3_bucket.artfacts_s3_bucket.id}"
    type = "S3"
  }

  "stage" {
    name = "Source"
    "action" {
      category = "Source"
      name = "Source"
      owner = "AWS"
      provider = "CodeCommit"
      version = "1"
      output_artifacts = ["${var.app_name}-${var.environment}-source-artifact"]

      configuration {
        BranchName = "master"
        RepositoryName = "${aws_codecommit_repository.application-codecommit-repo.repository_name}"
      }
      run_order = 1
    }
  }

  stage {
    name = "Build"
    "action" {
      category = "Build"
      name = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      version = "1"

      input_artifacts = [ "${var.app_name}-${var.environment}-source-artifact" ]
      output_artifacts = [ "${var.app_name}-${var.environment}-build-artifact" ]

      configuration {
        ProjectName = "${aws_codebuild_project.application-codebuild-project.id}"
      }
      run_order = 1
    }
  }

  stage {
    name = "Deploy"
    "action" {
      category = "Deploy"
      name = "Deploy"
      owner = "AWS"
      provider = "ECS"
      version = "1"

      input_artifacts = [ "${var.app_name}-${var.environment}-build-artifact" ]

      configuration {
        ClusterName = "${var.ecs_cluster_id}"
        ServiceName = "${var.ecs_service_id}"
        FileName = "imagedefinitions.json"
      }
    }
  }
}