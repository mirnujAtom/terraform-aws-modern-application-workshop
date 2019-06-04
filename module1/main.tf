provider "aws" {
  version = "~> 1.16"
  profile = "personal"
  region = "us-east-1"
}

terraform {
  backend "s3" {
    key = "mypizdiuchky-state/module1.tfstate"
    bucket = "mypizdiuchky-state"
    profile = "personal"
    region = "us-east-1"
  }
}



resource "aws_s3_bucket" "mypizdiuchky" {

  bucket = "mypizdiuchky"
  acl = "public-read"

  website {
    index_document = "index.html"
  }
}

data "aws_iam_policy_document" "mypizdiuchky" {
  statement {
    effect = "Allow"
    actions = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.mypizdiuchky.arn}", "${aws_s3_bucket.mypizdiuchky.arn}/*"]
    principals {
      identifiers = ["*"]
      type = "AWS"
    }

  }
}

resource "aws_s3_bucket_policy" "mypizdiuchky" {
  bucket = "${aws_s3_bucket.mypizdiuchky.id}"
  policy = "${data.aws_iam_policy_document.mypizdiuchky.json}"
}

resource "aws_s3_bucket_object" "indexfile" {
  bucket = "${aws_s3_bucket.mypizdiuchky.id}"
  key = "index.html"
  source = "files/index.html"
  content_type = "text/html"
}