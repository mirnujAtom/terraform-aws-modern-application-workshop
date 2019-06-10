resource "aws_s3_bucket" "site_s3_bucket" {

  bucket = "${var.app_name}-${var.environment}"
  acl = "public-read"
  force_destroy = true

  website {
    index_document = "index.html"
  }
}

data "aws_iam_policy_document" "site_s3_iam_policy_document" {
  statement {
    effect = "Allow"
    actions = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.site_s3_bucket.arn}", "${aws_s3_bucket.site_s3_bucket.arn}/*"]
    principals {
      identifiers = ["*"]
      type = "AWS"
    }

  }
}

resource "aws_s3_bucket_policy" "site_s3_bucket_policy" {
  bucket = "${aws_s3_bucket.site_s3_bucket.id}"
  policy = "${data.aws_iam_policy_document.site_s3_iam_policy_document.json}"
}


data "template_file" "site_index_file" {
  template = "${file("${var.site_files_dir}/index.html")}"
  vars = {
    region = "${var.region}"
    app_user_pool_client = "${var.app_user_pool_client}"
    app_api_endpoint = "${var.app_api_endpoint}"
    app_user_pool_id = "${var.app_user_pool_id}"
  }
}

resource "aws_s3_bucket_object" "indexfile" {
  bucket = "${aws_s3_bucket.site_s3_bucket.id}"
  key = "index.html"
  content = "${data.template_file.site_index_file.rendered}"
  content_type = "text/html"
  depends_on = [ "data.template_file.site_index_file" ]
  etag = "${md5(data.template_file.site_index_file.rendered)}"

}


data "template_file" "site_confirm_file" {
  template = "${file("${var.site_files_dir}/confirm.html")}"
  vars = {
    app_user_pool_client = "${var.app_user_pool_client}"
    app_user_pool_id = "${var.app_user_pool_id}"
  }
}

resource "aws_s3_bucket_object" "confirm_file" {
  bucket = "${aws_s3_bucket.site_s3_bucket.id}"
  key = "confirm.html"
  content = "${data.template_file.site_confirm_file.rendered}"
  content_type = "text/html"
  depends_on = [ "data.template_file.site_confirm_file" ]
  etag = "${md5(data.template_file.site_confirm_file.rendered)}"

}

data "template_file" "site_register_file" {
  template = "${file("${var.site_files_dir}/register.html")}"
  vars = {
    app_user_pool_client = "${var.app_user_pool_client}"
    app_user_pool_id = "${var.app_user_pool_id}"
  }
}

resource "aws_s3_bucket_object" "register_file" {
  bucket = "${aws_s3_bucket.site_s3_bucket.id}"
  key = "register.html"
  content = "${data.template_file.site_register_file.rendered}"
  content_type = "text/html"
  depends_on = [ "data.template_file.site_register_file" ]
  etag = "${md5(data.template_file.site_register_file.rendered)}"

}


resource "aws_s3_bucket_object" "amazon-cognito-identity" {
  bucket = "${aws_s3_bucket.site_s3_bucket.id}"
  key = "js/amazon-cognito-identity.min.js"
  source = "${var.site_files_dir}/js/amazon-cognito-identity.min.js"
}

resource "aws_s3_bucket_object" "amazon-cognito-sdk-min" {
  bucket = "${aws_s3_bucket.site_s3_bucket.id}"
  key = "js/aws-cognito-sdk.min.js"
  source = "${var.site_files_dir}/js/aws-cognito-sdk.min.js"
}

resource "aws_s3_bucket_object" "amazon-cognito-sdk" {
  bucket = "${aws_s3_bucket.site_s3_bucket.id}"
  key = "js/aws-sdk-2.246.1.min.js"
  source = "${var.site_files_dir}/js/aws-sdk-2.246.1.min.js"
}