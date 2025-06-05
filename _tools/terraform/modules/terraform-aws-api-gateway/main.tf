//---------------------
// API Gateway
//---------------------
resource "aws_apigatewayv2_api" "api" {
  name          = format("apigw-%s-%s", var.env, var.service)
  protocol_type = var.protocol_type
  description   = var.api_description

  disable_execute_api_endpoint = var.disable_execute_api_endpoint

  cors_configuration {
    allow_methods = ["OPTIONS", "POST", "GET"]
    allow_origins = ["*"]
    allow_headers = ["Content-Type,Authorization"]
  }

  tags = {
    Environment = var.env,
    Stack       = "common",
    Role        = "api_gateway"
  }
}

//---------------------
// Stages
//---------------------
resource "aws_apigatewayv2_stage" "stage" {
  api_id = aws_apigatewayv2_api.api.id

  name        = format("stage-%s-%s", var.env, var.service)
  auto_deploy = var.auto_deploy

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.log_group.arn

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

  default_route_settings {
    logging_level            = var.logging_level
    detailed_metrics_enabled = var.detailed_metrics_enabled
  }

  tags = {
    Environment = var.env,
    Stack       = "common",
    Role        = "api_gateway_stage"
  }
}

//---------------------
// API integration
//---------------------
resource "aws_apigatewayv2_integration" "integration" {
  api_id             = aws_apigatewayv2_api.api.id
  integration_uri    = var.integration_uri
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  // connection_id = aws_apigatewayv2_vpc_link.link.id
}

resource "aws_apigatewayv2_route" "route" {
  api_id = aws_apigatewayv2_api.api.id

  route_key = "GET /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.integration.id}"
}

//---------------------
// Cloudwatch log
//---------------------
resource "aws_cloudwatch_log_group" "log_group" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.api.name}"

  retention_in_days = 30
}

//---------------------
// Permissions
//---------------------
resource "aws_lambda_permission" "perms" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

//---------------------
// VPC Links
//---------------------
resource "aws_apigatewayv2_vpc_link" "link" {
  name               = format("vpc-link-%s", var.env)
  security_group_ids = var.security_group_ids
  subnet_ids         = var.subnet_ids

  tags = {
    Environment = var.env,
    Stack       = "common",
    Role        = "vpc_link"
  }
}

//---------------------
// Custom domain
//---------------------
resource "aws_apigatewayv2_domain_name" "domain" {
  domain_name = format("api.%s", var.public_domain)

  domain_name_configuration {
    certificate_arn = var.certificat_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }

  tags = {
    Environment = var.env,
    Stack       = "common",
    Role        = "api_domain_name"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_apigatewayv2_api_mapping" "api_mapping" {
  api_id      = aws_apigatewayv2_api.api.id
  domain_name = aws_apigatewayv2_domain_name.domain.id
  stage       = aws_apigatewayv2_stage.stage.id
}

resource "aws_route53_record" "api_record" {
  name    = aws_apigatewayv2_domain_name.domain.domain_name
  type    = "A"
  zone_id = var.public_host_zone_id

  alias {
    name                   = aws_apigatewayv2_domain_name.domain.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.domain.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}
