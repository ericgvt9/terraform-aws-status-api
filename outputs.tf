output "invoke_url" {
  description = "Deployed status API endpoint"
  value       = "${aws_api_gateway_deployment.rest_api.invoke_url}"
}

output "api_key" {
  description = "Generated API key"
  value       = "${aws_api_gateway_api_key.default_api_key.value}"
}
