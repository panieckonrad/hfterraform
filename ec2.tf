resource "aws_instance" "bastion" {
  ami               = "ami-06ee70bcb5d664ce9"
  instance_type     = "t4g.micro"
  availability_zone = "eu-west-1c"
  key_name          = "hfec2key"
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.ni.id
  }
  user_data         = file("ec2setup.sh")
  tags              = {
    Name    = "hf-bastion"
    Pricing = "hf"
  }
}