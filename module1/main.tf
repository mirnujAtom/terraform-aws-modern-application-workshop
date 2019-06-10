provider "aws" {
  version = "~> 1.16"
  profile = "personal"
  region = "us-east-1"
}

terraform {
  backend "s3" {
    key = "module1/module1.tfstate"
    bucket = "module1-state"
    profile = "personal"
    region = "us-east-1"
  }
}



resource "aws_s3_bucket" "site_bucket" {

  bucket = "${var.site_name}"
  acl = "public-read"

  website {
    index_document = "index.html"
  }
}

data "aws_iam_policy_document" "site_policy_document" {
  statement {
    effect = "Allow"
    actions = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.site_bucket.arn}", "${aws_s3_bucket.site_bucket.arn}/*"]
    principals {
      identifiers = ["*"]
      type = "AWS"
    }

  }
}

resource "aws_s3_bucket_policy" "site_policy" {
  bucket = "${aws_s3_bucket.site_bucket.id}"
  policy = "${data.aws_iam_policy_document.site_policy_document.json}"
}

resource "aws_s3_bucket_object" "indexfile" {
  bucket = "${aws_s3_bucket.site_bucket.id}"
  key = "index.html"
  source = "files/index.html"
  content_type = "text/html"
}