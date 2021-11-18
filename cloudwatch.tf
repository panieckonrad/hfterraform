resource "aws_cloudwatch_log_group" "kafka-connect" {
  name = "kafka-connect"

  tags = {
    Name    = "kafka-connect"
    Pricing = "hf"
  }
}