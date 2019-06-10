provider "aws" {
  version = "~> 1.16"
  profile = "${var.profile}"
  region = "${var.region}"
}

terraform {
  backend "s3" {
    key = "mysite-state/module4.tfstate"
    bucket = "module4-app-state"
    profile = "personal"
    region = "us-east-1"
  }
}


data "aws_caller_identity" "current" {}


data "terraform_remote_state" "platform_state" {
  backend = "s3"
  config {
    key = "myplatform-state/module4-platform.tfstate"
    bucket = "module4-platform-state"
    profile = "personal"
    region = "us-east-1"
  }

}

module "ecs" {
  source = "../../modules/ecs"
  app_name = "${var.app_name}"
  app_version = "${var.app_version}"
  environment = "${var.environment}"
  account_id = "${data.aws_caller_identity.current.account_id}"
  region = "${var.region}"
  private_subnets = "${data.terraform_remote_state.platform_state.private_subnets}"
  lb_target_group_arn = "${data.terraform_remote_state.platform_state.lb_target_group_arn}"
  vpc_id = "${data.terraform_remote_state.platform_state.vpc_id}"
}

module "s3site" {
  source = "../../modules/s3site"
  app_name = "${var.app_name}"
  environment = "${var.environment}"
  region = "${var.region}"
  site_files_dir = "${var.site_files_dir}"
  lb_address = "${data.terraform_remote_state.platform_state.lb_address}"
  app_api_endpoint = "${module.authentication.app_api_endpoint}"
  app_user_pool_id = "${module.authentication.app_user_pool_id}"
  app_user_pool_client = "${module.authentication.app_user_pool_client}"
}

module "cicd" {
  source = "../../modules/cicd"
  app_name = "${var.app_name}"
  region = "${var.region}"
  environment = "${var.environment}"
  account_id = "${data.aws_caller_identity.current.account_id}"
  ecs_service_id = "${module.ecs.ecs_service_id}"
  ecs_cluster_id = "${module.ecs.ecs_cluster_id}"
  ecr_repo_name = "${module.ecs.ecr_repo_name}"
}

module "dynamodb" {
  source = "../../modules/dynamodb"
  table_name = "${var.app_name}-${var.environment}-table"
  app_name = "${var.app_name}"
  region = "${var.region}"
  environment = "${var.environment}"
}

module "authentication" {
  source = "../../modules/authentication"
  app_name = "${var.app_name}"
  region = "${var.region}"
  environment = "${var.environment}"
  lb_arn = "${data.terraform_remote_state.platform_state.lb_arn}"
  account_id = "${data.aws_caller_identity.current.account_id}"
  lb_address = "${data.terraform_remote_state.platform_state.lb_address}"
  application_rest_api_swagger = "${var.application_rest_api_swagger}"
}