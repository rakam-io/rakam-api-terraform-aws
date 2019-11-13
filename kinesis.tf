resource "aws_kinesis_stream" "rakamstream" {
  name             = "terraform-kinesis-rakam"
  shard_count      = 1
  retention_period = 48

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  tags = {
    Name = "terraform-kinesis-rakam"
  }
}