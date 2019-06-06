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

data aws_availability_zones "avz" {}
data "aws_caller_identity" "current" {}

module "platform" {
  source = "modules/platform"
  avz_names = [ "${data.aws_availability_zones.avz.names[0]}", "${data.aws_availability_zones.avz.names[1]}" ]
  vpc_cidr = "10.10.0.0/16"
  public_subnets = [ "10.10.0.0/24", "10.10.1.0/24" ]
  private_subnets = [ "10.10.2.0/24", "10.10.3.0/24" ]
  app_name = "${var.app_name}"
  profile = "${var.profile}"
  region = "${var.region}"
  account_id = "${data.aws_caller_identity.current.account_id}"
  environment = "${var.environment}"
}


module "ecs" {
  source = "modules/ecs"
  app_name = "${var.app_name}"
  environment = "${var.environment}"
  ecs_service_role_arn = "${module.platform.ecs_service_role_arn}"
  ecs_task_role_arn = "${module.platform.ecs_task_role_arn}"
  app_image = "${var.app_image}"
  region = "${var.region}"
  private_subnets = "${module.platform.private_subnets}"
  fg_sg_id = "${module.platform.fargate_container_security_group_id}"
  lb_target_group_arn = "${module.platform.lb_target_group_arn}"
}

module "s3site" {
  source = "modules/s3site"
  app_name = "${var.app_name}"
  environment = "${var.environment}"
  region = "${var.region}"
  index_template = "${var.index_template}"
  lb_address = "${module.platform.lb_address}"
}

module "cicd" {
  source = "modules/cicd"
  app_name = "${var.app_name}"
  region = "${var.region}"
  environment = "${var.environment}"
  code_pipeline_role_arn = "${module.platform.code_pipeline_role_arn}"
  code_build_role_arn = "${module.platform.code_build_role_arn}"
}