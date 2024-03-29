provider "aws" {
  version = "~> 1.16"
  profile = "${var.profile}"
  region = "${var.region}"
}

terraform {
  backend "s3" {
    key = "myplatform-state/module2-platform.tfstate"
    bucket = "module2-platform-state"
    profile = "personal"
    region = "us-east-1"
  }
}

data aws_availability_zones "avz" {}
data "aws_caller_identity" "current" {}

module "platform" {
  source = "../../modules/platform"
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
