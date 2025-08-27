# Create an SNS topic for notifications
resource "aws_sns_topic" "alerts" {
  name = "asg-alerts-topic"
}

# Subscribe your email address to the SNS topic
resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "m.abouchiba0@gmail.com" # REPLACE WITH YOUR EMAIL
}

# This IAM policy allows CloudWatch alarms to publish to your SNS topic
resource "aws_sns_topic_policy" "default" {
  arn    = aws_sns_topic.alerts.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]
    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }
    resources = [aws_sns_topic.alerts.arn]
  }
}

# Alarm for the Frontend ASG CPU High
resource "aws_cloudwatch_metric_alarm" "frontend_asg_cpu_high" {
  alarm_name          = "frontend-asg-cpu-utilization-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"    # How many periods to evaluate
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"  # Evaluation period in seconds (2 minutes)
  statistic           = "Average"
  threshold           = "80"   # CPU percentage threshold
  alarm_description   = "This alarm monitors frontend EC2 CPU for scaling out"
  alarm_actions       = [aws_sns_topic.alerts.arn] # Send to SNS topic

  # This links the alarm to the specific Auto Scaling Group
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.public_autoscaling_group.name
  }
}

# Alarm for the Backend ASG CPU High
resource "aws_cloudwatch_metric_alarm" "backend_asg_cpu_high" {
  alarm_name          = "backend-asg-cpu-utilization-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This alarm monitors backend EC2 CPU for scaling out"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.private_autoscaling_group.name
  }
}

# Alarm for ASG Instance Launch Failures
resource "aws_cloudwatch_metric_alarm" "asg_failed_instance_launch" {
  alarm_name          = "asg-failed-instance-launch"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FailedInstanceLaunch"
  namespace           = "AWS/AutoScaling"
  period              = "60"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "Alarm when ASG fails to launch an instance"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.public_autoscaling_group.name
  }
}