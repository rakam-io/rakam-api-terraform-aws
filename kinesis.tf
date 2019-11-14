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