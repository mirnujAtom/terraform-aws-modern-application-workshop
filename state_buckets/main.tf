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

resource "aws_s3_bucket" "module3_platform_state" {
  bucket = "module3-platform-state"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}


resource "aws_s3_bucket" "module3_app_state" {
  bucket = "module3-app-state"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket" "module4_platform_state" {
  bucket = "module4-platform-state"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}


resource "aws_s3_bucket" "module4_app_state" {
  bucket = "module4-app-state"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}


resource "aws_s3_bucket" "module5_platform_state" {
  bucket = "module5-platform-state"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}


resource "aws_s3_bucket" "module5_app_state" {
  bucket = "module5-app-state"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}