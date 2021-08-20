// API Gateway
resource "aws_apigatewayv2_api" "lambda" {
  name          = format("apigw-%s-%s", var.env, var.service)
  protocol_type = var.protocol_type
}

// Stages
resource "aws_apigatewayv2_stage" "lambda" {
  api_id = aws_apigatewayv2_api.lambda.id

  name        = format("lambda-%s-%s", var.env, var.service)
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

// API integration
resource "aws_apigatewayv2_integration" "this" {
  api_id = aws_apigatewayv2_api.lambda.id

  //   integration_uri    = aws_lambda_function.hello_world.invoke_arn
  integration_uri    = var.integration_uri
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "this" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "GET /hello"
  target    = "integrations/${aws_apigatewayv2_integration.this.id}"
}

// Cloudwatch log
resource "aws_cloudwatch_log_group" "api_gw" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.lambda.name}"

  retention_in_days = 30
}

// Permissions
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}

// VPC Links
resource "aws_apigatewayv2_vpc_link" "api_gw" {
  name               = format("vpc-link-%s", var.env)
  security_group_ids = var.security_group_ids
  subnet_ids         = var.subnet_ids

  tags = {
    Environment = var.env,
    Stack       = "common",
    Role        = "vpc_link"
  }
}

// Custom domain
resource "aws_apigatewayv2_domain_name" "this" {
  domain_name = format("api.%s", var.public_domain)

  domain_name_configuration {
    certificate_arn = var.certificat_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_route53_record" "api_record" {
  name    = aws_apigatewayv2_domain_name.this.domain_name
  type    = "A"
  zone_id = var.public_host_zone_id

  alias {
    name                   = aws_apigatewayv2_domain_name.this.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.this.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}
