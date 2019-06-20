output "app_api_endpoint" {
  value = "${aws_api_gateway_deployment.application_api_deployment.invoke_url}"
}
output "app_user_pool_id" {
  value = "${aws_cognito_user_pool.application_user_pool.id}"
}
output "app_user_pool_client" {
  value = "${aws_cognito_user_pool_client.application_user_pool_client.id}"
}