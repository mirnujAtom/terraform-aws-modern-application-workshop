provider "aws" {
  region = "us-east-1"
  version = "~> 1.16"
  profile = "personal"
}

resource "aws_s3_bucket" "module1-state" {
  bucket = "mypizdiuchky-state"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}



resource "aws_s3_bucket" "module2_platform_state" {
  bucket = "module2-platform-state"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}


resource "aws_s3_bucket" "module2_app_state" {
  bucket = "module2-app-state"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}