output "invoke_url" {
  description = "Deployed status API endpoint"
  value       = "${aws_api_gateway_deployment.rest_api.invoke_url}"
}
