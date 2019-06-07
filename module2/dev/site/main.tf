provider "aws" {
  version = "~> 1.16"
  profile = "${var.profile}"
  region = "${var.region}"
}

terraform {
  backend "s3" {
    key = "mypizdiuchky-state/module2.tfstate"
    bucket = "mypizdiuchky-state"
    profile = "personal"
    region = "us-east-1"
  }
}



data "aws_caller_identity" "current" {}


data "terraform_remote_state" "platform_state" {
  backend = "s3"
  config {
    key = "mypizdiuchky-state/module2-platform.tfstate"
    bucket = "module2-platform-state"
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
  index_template = "${var.index_template}"
  lb_address = "${data.terraform_remote_state.platform_state.lb_address}"
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
