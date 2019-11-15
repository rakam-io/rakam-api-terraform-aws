resource "aws_kinesis_stream" "rakamstream" {
  name             = "terraform-kinesis-rakam"
  shard_count      = var.rakam-collector-kinesis-shard-count
  retention_period = 48

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  tags = {
    Name = "terraform-kinesis-rakam"
  }
}

# Create a cloudwatch alarm for kinesis checking on throughput activity
resource "aws_cloudwatch_metric_alarm" "r-api-kinesis-alarm" {
  alarm_name          = "Kinesis Throughout Exceeded"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "WriteProvisionedThroughputExceeded"
  namespace           = "AWS/Kinesis"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  treat_missing_data  = "notBreaching"
  alarm_description   = "Kinesis Throughout Exceeded"
}