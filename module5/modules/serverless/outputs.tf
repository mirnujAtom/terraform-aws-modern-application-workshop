output "lambdaa_api_endpoint" {
  value = "${aws_api_gateway_deployment.click-processor-rest-api-deployment.invoke_url}"
}