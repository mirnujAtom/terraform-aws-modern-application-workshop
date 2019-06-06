resource "aws_s3_bucket" "artfacts_s3_bucket" {
  bucket = "${var.app_name}-${var.environment}-artifacts-bucket"

}

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
        "${var.code_build_role_arn}",
        "${var.code_pipeline_role_arn}"
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
        "${var.code_build_role_arn}",
        "${var.code_pipeline_role_arn}"
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "site_s3_bucket_policy" {
  bucket = "${aws_s3_bucket.artfacts_s3_bucket.id}"
  policy = "${data.aws_iam_policy_document.artifacts_s3_iam_policy_document.json}"
}