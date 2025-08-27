  # Internal ALB for backend tier (Unchanged)
  resource "aws_lb" "internal_alb" {
    name               = "backend-alb"
    internal           = true
    load_balancer_type = "application"
    security_groups    = [aws_security_group.internal_alb_sg.id]
    subnets            = [aws_subnet.private_subnet_3.id, aws_subnet.private_subnet_4.id]
  }

  resource "aws_lb_target_group" "backend_tg" {
    name     = "backend-target-group"
    port     = 3001
    protocol = "HTTP"
    vpc_id   = aws_vpc.main.id

    health_check {
      path                = "/health"
      interval            = 30
      timeout             = 5
      healthy_threshold   = 2
      unhealthy_threshold = 2
    }
  }

  resource "aws_lb_listener" "backend_listener" {
    load_balancer_arn = aws_lb.internal_alb.arn
    port              = 80
    protocol          = "HTTP"
    default_action {
      type             = "forward"
      target_group_arn = aws_lb_target_group.backend_tg.arn
    }
  }

  #------------------------------------------------------------------------------------------------------------

  # External Application Load Balancer (Unchanged)
  resource "aws_lb" "external_alb" {
    name               = "external-frontend-alb"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.LB_SG.id]
    subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
    enable_deletion_protection = false
    tags = { Name = "external-frontend-alb" }
  }

  resource "aws_lb_target_group" "frontend_tg" {
    name     = "frontend-target-group"
    port     = 80
    protocol = "HTTP"
    vpc_id   = aws_vpc.main.id

    health_check {
      path                = "/health"
      protocol            = "HTTP"
      interval            = 30
      timeout             = 5
      healthy_threshold   = 2
      unhealthy_threshold = 2
      matcher             = "200"
    }
  }

  # HTTP Listener for the External ALB (ONLY LISTENER NEEDED)
  resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.external_alb.arn
    port              = 80
    protocol          = "HTTP"

    default_action {
      type             = "forward"
      target_group_arn = aws_lb_target_group.frontend_tg.arn
    }
  }

  #------------------------------------------------------------------------------------------------------------

  # Create a custom origin request policy to forward ALL headers
  resource "aws_cloudfront_origin_request_policy" "api_origin_request_policy" {
    name    = "API-Origin-Request-Policy"
    comment = "Forwards all viewer headers and cookies for API requests"

    cookies_config {
      cookie_behavior = "all"
    }

    headers_config {
      header_behavior = "allViewer" 
    }

    query_strings_config {
      query_string_behavior = "all"
    }
  }

  # CloudFront Distribution - Uses Default AWS Certificate
  resource "aws_cloudfront_distribution" "main" {
    origin {
      domain_name = aws_lb.external_alb.dns_name
      origin_id   = "ALBOrigin"


      custom_origin_config {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }

    enabled         = true
    is_ipv6_enabled = true
    comment         = "My CloudFront Distribution"

    # DEFAULT Behavior: For static assets
    default_cache_behavior {
      allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
      cached_methods   = ["GET", "HEAD"]
      target_origin_id = "ALBOrigin"
      compress         = true
      cache_policy_id  = "658327ea-f89d-4fab-a63d-7e88639e58f6" # Managed-CachingOptimized
      viewer_protocol_policy = "redirect-to-https"
      min_ttl                = 0
      default_ttl            = 3600
      max_ttl                = 86400
    }

    # API Behavior: For API paths, disable caching and forward all headers
    ordered_cache_behavior {
      path_pattern     = "/api/*"
      allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
      cached_methods   = ["GET", "HEAD"]
      target_origin_id = "ALBOrigin"
      cache_policy_id  = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # Managed-CachingDisabled
      origin_request_policy_id = aws_cloudfront_origin_request_policy.api_origin_request_policy.id
      viewer_protocol_policy = "redirect-to-https"
    }

    price_class = "PriceClass_100"

    viewer_certificate {
      cloudfront_default_certificate = true
      ssl_support_method             = "sni-only"
    }

    restrictions {
      geo_restriction {
        restriction_type = "none"
      }
    }

    tags = {
      Name = "main-distribution"
    }
  }

  # This data source is provided by AWS.
  data "aws_ec2_managed_prefix_list" "cloudfront" {
    name = "com.amazonaws.global.cloudfront.origin-facing"
  }

  # This rule locks down the ALB to only allow traffic from CloudFront's IPs
  resource "aws_security_group_rule" "allow_cloudfront_to_alb" {
    description       = "Allow HTTP from CloudFront to the ALB"
    type              = "ingress"
    from_port         = 80
    to_port           = 80
    protocol          = "tcp"
    prefix_list_ids   = [data.aws_ec2_managed_prefix_list.cloudfront.id]
    security_group_id = aws_security_group.LB_SG.id
  }