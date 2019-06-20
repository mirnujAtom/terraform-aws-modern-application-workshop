output "table_arn" {
  value = "${aws_dynamodb_table.application_dynamodb_table.arn}"
}