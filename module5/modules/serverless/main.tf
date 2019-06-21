resource "aws_codecommit_repository" "app-streaming-service-repo" {
  repository_name = "${var.app_name}-${var.environment}-streaming-service-repo"
}


resource "aws_s3_bucket" "click-destination-bucket" {
  bucket = "${var.app_name}-${var.environment}-click-destination"
  versioning {
    enabled = true
  }
}


data "template_file" "lambda-code" {
  template = "${file("${var.lambda_files_dir}/streaming/streamingProcessor.go")}"
  vars = {
    app_api_endpoint = "${var.app_api_endpoint}"
  }
}

data "archive_file" "lambda" {
  type = "zip"
  output_path = "${var.lambda_files_dir}/streaming/streamingProcessor.go.zip"
  source_content_filename = "streamingProcessor.go"
  source_content = "${data.template_file.lambda-code.rendered}"
}

resource "aws_lambda_function" "application-click-processor-function" {
  function_name = "${var.app_name}-${var.environment}-click-processor"
  handler = "streamProcessor.processRecord"
  role = "${aws_iam_role.app-lambda-role.arn}"
  runtime = "go1.x"
  memory_size = 128
  timeout = 30
  filename = "${data.archive_file.lambda.output_path}"
  source_code_hash = "${data.archive_file.lambda.output_base64sha256}"
}

resource "aws_kinesis_firehose_delivery_stream" "app-firehouse-to-s3" {
  destination = "extended_s3"
  name = "${var.app_name}-${var.environment}-firehouse-delivery-stream"
  extended_s3_configuration {
    bucket_arn = "${aws_s3_bucket.click-destination-bucket.arn}"
    role_arn = "${aws_iam_role.firehouse-delivery-role.arn}"
    buffer_interval = 60
    buffer_size = 50
    compression_format = "UNCOMPRESSED"
    prefix = "firehose/"
    processing_configuration {
      enabled = true
      processors {
        type = "Lambda"
        parameters {
          parameter_name = "LambdaArn"
          parameter_value = "${aws_lambda_function.application-click-processor-function.arn}"
        }
      }
    }
  }
}

resource "aws_lambda_permission" "application-lambda-permission" {
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.application-click-processor-function.function_name}"
  principal = "firehose.amazonaws.com"
  source_account = "${var.account_id}"
  source_arn = "${aws_kinesis_firehose_delivery_stream.app-firehouse-to-s3.arn}"
}


//////////////////
resource "aws_api_gateway_rest_api" "click-processor-rest-api" {
  name = "${var.app_name}-${var.environment}-click-processor-rest-api"
  endpoint_configuration {
    types = [ "REGIONAL" ]
  }
  body = "${data.template_file.click-processor-rest-api-swagger.rendered}"
}

data "template_file" "click-processor-rest-api-swagger" {
  template = "${file("${var.click_processor_rest_api_swagger}")}"
  vars = {
    API_NAME = "${var.app_name}-${var.environment}-click-processor-rest-api"
    REGION = "${var.region}"
    click-processing-api-role = "${aws_iam_role.click-processing-api-role.arn}"
    app-firehouse-to-s3 = "${aws_kinesis_firehose_delivery_stream.app-firehouse-to-s3.id}"
  }
}


/*resource "aws_api_gateway_resource" "click-processor-rest-api-resource" {
  parent_id = "${aws_api_gateway_rest_api.click-processor-rest-api.root_resource_id}"
  path_part = "/clicks"
  rest_api_id = "${aws_api_gateway_rest_api.click-processor-rest-api.id}"

}*/



resource "aws_api_gateway_deployment" "click-processor-rest-api-deployment" {
  rest_api_id = "${aws_api_gateway_rest_api.click-processor-rest-api.id}"
  stage_name = "${var.environment}"
}


data "aws_api_gateway_resource" "click-processor-rest-api-resource" {
  path = "/clicks"
  rest_api_id = "${aws_api_gateway_rest_api.click-processor-rest-api.id}"
}



/*resource "aws_api_gateway_model" "Empty-model" {
  content_type = "application/json"
  name = "Empty"
  rest_api_id = "${aws_api_gateway_rest_api.click-processor-rest-api.id}"
  schema = "{}"
}*/


/*module "cors" {
  source = "github.com/squidfunk/terraform-aws-api-gateway-enable-cors"
  version = "0.3.0"

  api_id          = "${aws_api_gateway_rest_api.click-processor-rest-api.id}"
  api_resource_id = "${data.aws_api_gateway_resource.click-processor-rest-api-resource.id}"

  allow_headers = [
    "Content-Type"
  ]
}*/

resource "aws_api_gateway_rest_api" "testapi" {
  name = "just-a-test-terraform"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}



module "cors" {
  source = "mewa/apigateway-cors/aws"
  version = "1.0.0"

  api          = "${aws_api_gateway_rest_api.click-processor-rest-api.id}"
  resource = "${data.aws_api_gateway_resource.click-processor-rest-api-resource.id}"

  headers =  ["'Content-Type'"]

  methods = ["GET", "POST"]
}



