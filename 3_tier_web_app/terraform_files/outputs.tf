# Output the public LB URL, just for testing that it is not accessible
output "external_alb_url" {
  description = "Full URL of the external load balancer"
  value       = "http://${aws_lb.external_alb.dns_name}"
}

# Output the CloudFront URL
output "cloudfront_url" {
  description = "The URL of the CloudFront distribution"
  value       = "https://${aws_cloudfront_distribution.main.domain_name}"
}