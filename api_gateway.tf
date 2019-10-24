
resource "aws_api_gateway_rest_api" "example" {
  name        = "${var.module_name}"
  description = "Terraform Serverless Application Example"
}

resource "aws_api_gateway_resource" "status" {
  rest_api_id = "${aws_api_gateway_rest_api.example.id}"
  parent_id   = "${aws_api_gateway_rest_api.example.root_resource_id}"
  path_part   = "status"
}

resource "aws_api_gateway_resource" "statusId" {
  rest_api_id = "${aws_api_gateway_rest_api.example.id}"
  parent_id   = "${aws_api_gateway_resource.status.id}"
  path_part   = "{id}"
}

resource "aws_api_gateway_method" "get_status" {
  rest_api_id   = "${aws_api_gateway_rest_api.example.id}"
  resource_id   = "${aws_api_gateway_resource.statusId.id}"
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.id" = true
  }
}

resource "aws_api_gateway_integration" "get_status_integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.example.id}"
  resource_id             = "${aws_api_gateway_resource.statusId.id}"
  http_method             = "${aws_api_gateway_method.get_status.http_method}"
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = "${aws_lambda_function.example.invoke_arn}"
  passthrough_behavior    = "WHEN_NO_MATCH"

  request_parameters = {
    "integration.request.path.id" = "method.request.path.id"
  }
}

resource "aws_api_gateway_deployment" "example" {
  depends_on = [
    "aws_api_gateway_integration.get_status_integration"
  ]

  rest_api_id = "${aws_api_gateway_rest_api.example.id}"
  stage_name  = "${var.stage}"
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.example.function_name}"
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.example.execution_arn}/*/*"
}

output "base_url" {
  value = "${aws_api_gateway_deployment.example.invoke_url}"
}
