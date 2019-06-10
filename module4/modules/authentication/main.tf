resource "aws_cognito_user_pool" "application_user_pool" {
  name = "${var.app_name}-${var.environment}-user-pool"
  auto_verified_attributes = ["email"]
}

resource "aws_cognito_user_pool_client" "application_user_pool_client" {
  name = "${var.app_name}-${var.environment}-user-pool-client"
  user_pool_id = "${aws_cognito_user_pool.application_user_pool.id}"
}

resource "aws_api_gateway_vpc_link" "application_api_vpc_link" {
  name = "${var.app_name}-${var.environment}-api-vpc-link"
  target_arns = ["${var.lb_arn}"]
}

resource "aws_api_gateway_rest_api" "application_rest_api" {
  name = "${var.app_name}-${var.environment}-rest-api"
  body = "${data.template_file.application_rest_api_swagger.rendered}"
}

data "template_file" "application_rest_api_swagger" {
  template = "${file("${var.application_rest_api_swagger}")}"
  vars = {
    API_NAME = "${var.app_name}-${var.environment}-rest-api"
    NLB_DNS = "${var.lb_address}"
    VPC_LINK_ID = "${aws_api_gateway_vpc_link.application_api_vpc_link.id}"
    REGION = "${var.region}"
    ACCOUNT_ID = "${var.account_id}"
    COGNITO_USER_POOL_ID = "${aws_cognito_user_pool.application_user_pool.id}"
  }
}

resource "aws_api_gateway_deployment" "application_api_deployment" {
  rest_api_id = "${aws_api_gateway_rest_api.application_rest_api.id}"
  stage_name = "${var.environment}"
}