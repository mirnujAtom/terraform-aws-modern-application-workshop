resource "aws_dynamodb_table" "application_dynamodb_table" {
  hash_key = "MysfitId"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  name = "${var.app_name}-${var.environment}-table"

  "attribute"  {
    name = "MysfitId"
    type = "S"
  }
  attribute {
    name = "GoodEvil"
    type = "S"
  }
  attribute {
    name = "LawChaos"
    type = "S"
  }
  global_secondary_index {
    hash_key = "LawChaos"
    name = "LawChaosIndex"
    projection_type = "ALL"
    range_key = "MysfitId"
    read_capacity = 5
    write_capacity = 5
  }
  global_secondary_index {
    hash_key = "GoodEvil"
    name = "GoodEvilIndex"
    projection_type = "ALL"
    range_key = "MysfitId"
    read_capacity = 5
    write_capacity = 5
  }
}
