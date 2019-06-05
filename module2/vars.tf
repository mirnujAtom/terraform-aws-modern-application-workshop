variable "profile" {default = "personal"}
variable "region" {default = "us-east-1"}
variable "app_name" {default = "mypizdiuchky"}
variable "environment" {default = "dev"}
variable "app_image" {default = "171865172923.dkr.ecr.us-east-1.amazonaws.com/mypizdiuchky/service:latest"}
variable "index_template" {default = "files/index.html.tpl"}