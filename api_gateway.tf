
resource "aws_api_gateway_rest_api" "rest_api" {
  name        = "${var.module_name}"
  description = "${var.module_name} - Status Checking API Gateway"
}

resource "aws_api_gateway_resource" "status" {
  rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  parent_id   = "${aws_api_gateway_rest_api.rest_api.root_resource_id}"
  path_part   = "status"
}

resource "aws_api_gateway_resource" "status_id" {
  rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  parent_id   = "${aws_api_gateway_resource.status.id}"
  path_part   = "{id}"
}

resource "aws_api_gateway_method" "options_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.rest_api.id}"
  resource_id   = "${aws_api_gateway_resource.status_id.id}"
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "get_status" {
  rest_api_id   = "${aws_api_gateway_rest_api.rest_api.id}"
  resource_id   = "${aws_api_gateway_resource.status_id.id}"
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.id" = true
  }
}

resource "aws_api_gateway_method" "post_status" {
  rest_api_id      = "${aws_api_gateway_rest_api.rest_api.id}"
  resource_id      = "${aws_api_gateway_resource.status_id.id}"
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = true

  request_parameters = {
    "method.request.path.id" = true
  }
}

resource "aws_api_gateway_method_response" "options_200" {
  rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  resource_id = "${aws_api_gateway_resource.status_id.id}"
  http_method = "${aws_api_gateway_method.options_method.http_method}"
  status_code = 200
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
  depends_on = ["aws_api_gateway_method.options_method"]
}

resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  resource_id = "${aws_api_gateway_resource.status_id.id}"
  http_method = "${aws_api_gateway_method.options_method.http_method}"
  type        = "MOCK"
  depends_on  = ["aws_api_gateway_method.options_method"]
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  resource_id = "${aws_api_gateway_resource.status_id.id}"
  http_method = "${aws_api_gateway_method.options_method.http_method}"
  status_code = "${aws_api_gateway_method_response.options_200.status_code}"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = ["aws_api_gateway_method_response.options_200"]
}

resource "aws_api_gateway_integration" "get_status_integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.rest_api.id}"
  resource_id             = "${aws_api_gateway_resource.status_id.id}"
  http_method             = "${aws_api_gateway_method.get_status.http_method}"
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = "${aws_lambda_function.get_status_fn.invoke_arn}"
  passthrough_behavior    = "WHEN_NO_MATCH"

  request_parameters = {
    "integration.request.path.id" = "method.request.path.id"
  }
}

resource "aws_api_gateway_integration" "post_status_integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.rest_api.id}"
  resource_id             = "${aws_api_gateway_resource.status_id.id}"
  http_method             = "${aws_api_gateway_method.post_status.http_method}"
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = "${aws_lambda_function.update_status_fn.invoke_arn}"
  passthrough_behavior    = "WHEN_NO_MATCH"

  request_parameters = {
    "integration.request.path.id" = "method.request.path.id"
  }
}

resource "aws_api_gateway_deployment" "rest_api" {
  depends_on = [
    "aws_api_gateway_integration.get_status_integration",
    "aws_api_gateway_integration.post_status_integration"
  ]

  rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  stage_name  = "${var.stage}"
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.get_status_fn.function_name}"
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.rest_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "update_status_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.update_status_fn.function_name}"
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.rest_api.execution_arn}/*/*"
}

resource "aws_api_gateway_usage_plan" "default_usage_plan" {
  name        = "status-api-default-plan"
  description = "default usage plan for status-api for POST requests"

  api_stages {
    api_id = "${aws_api_gateway_rest_api.rest_api.id}"
    stage  = "${aws_api_gateway_deployment.rest_api.stage_name}"
  }
}

resource "aws_api_gateway_api_key" "default_api_key" {
  name        = "Default Status API Key"
  description = "Default API key generated to POST to status API"
}

resource "aws_api_gateway_usage_plan_key" "default_usage_plan_key" {
  key_id        = "${aws_api_gateway_api_key.default_api_key.id}"
  key_type      = "API_KEY"
  usage_plan_id = "${aws_api_gateway_usage_plan.default_usage_plan.id}"
}
