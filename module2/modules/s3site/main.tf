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
  template = "${file("${var.index_template}")}"
  vars = {
    lb_address = "${var.lb_address}"
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