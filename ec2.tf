resource "aws_instance" "bastion" {
  ami               = "ami-0ed961fa828560210"
  instance_type     = "t2.small"
  availability_zone = "eu-west-1c"
  key_name          = "hfec2key"
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.ni.id
  }
  iam_instance_profile = aws_iam_instance_profile.s3-kafka-connect-role1-instance.name
  user_data         = file("ec2setup.sh")
  tags              = {
    Name    = "hf-bastion"
    Pricing = "hf"
  }
}