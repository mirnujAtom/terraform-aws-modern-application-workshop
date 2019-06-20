resource "aws_iam_role" "firehouse-delivery-role" {
  name = "${var.app_name}-${var.environment}-firehouse-delivery-role"
  assume_role_policy = "${data.aws_iam_policy_document.firehouse-delivery-role-assume.json}"
}

data "aws_iam_policy_document" "firehouse-delivery-role-assume" {
  statement {
    effect = "Allow"
    actions = [ "sts:AssumeRole" ]
    principals {
      identifiers = [ "firehose.amazonaws.com" ]
      type = "Service"
    }
    condition {
      test = "StringEquals"
      values = ["${var.account_id}"]
      variable = "sts:ExternalId"
    }
  }
}


//////////////////////////

resource "aws_iam_role" "app-lambda-role" {
  name = "${var.app_name}-${var.environment}-click-processor-role"
  assume_role_policy = "${data.aws_iam_policy_document.app-lambda-role-assume.json}"
}

data "aws_iam_policy_document" "app-lambda-role-assume" {
  statement {
    effect = "Allow"
    actions = [ "sts:AssumeRole" ]
    principals {
      identifiers = [ "lambda.amazonaws.com" ]
      type = "Service"
    }
  }
}


data "aws_iam_policy_document" "app-lambda-policy-document" {
  statement {
    effect = "Allow"
    actions = [ "dynamodb:GetItem" ]
    resources = [
      "${var.table_arn}"
    ]
  }
}

resource "aws_iam_role_policy" "app-lambda-policy" {
  policy = "${data.aws_iam_policy_document.app-lambda-policy-document.json}"
  role = "${aws_iam_role.app-lambda-role.id}"
}

///////////////////////////

resource "aws_iam_role" "click-processing-api-role" {
  assume_role_policy = "${data.aws_iam_policy_document.click-processing-api-role-assume.json}"
  name = "${var.app_name}-${var.environment}-click-processing-api-role"
}

data "aws_iam_policy_document" "click-processing-api-role-assume" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"]
    principals {
      identifiers = [
        "apigateway.amazonaws.com"
      ]
      type = "Service"
    }
  }
}

data "aws_iam_policy_document" "click-processing-api-role-policy-document" {
  statement {
    effect = "Allow"
    actions = [
      "firehose:PutRecord"
    ]
    resources = [ "${aws_kinesis_firehose_delivery_stream.app-firehouse-to-s3.arn}" ]
  }
}

resource "aws_iam_role_policy" "click-processing-api-role-policy" {
  policy = "${data.aws_iam_policy_document.click-processing-api-role-policy-document.json}"
  role = "${aws_iam_role.click-processing-api-role.name}"
}