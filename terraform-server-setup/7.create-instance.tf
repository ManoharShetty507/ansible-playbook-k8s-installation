resource "aws_instance" "bastion" {
  ami                  = var.instance_ami_type
  instance_type        = var.instance_type_bastion
  key_name             = "testing-dev-1"
  subnet_id            = aws_subnet.dev_subnet_public_1.id
  iam_instance_profile = data.aws_iam_instance_profile.s3-access-profile.name
  vpc_security_group_ids = [
    aws_security_group.ssh.id,
    aws_security_group.web-traffic.id
  ]
  user_data = file("user-script-controller.sh")

  tags = {
    "Name"        = "bastion"
    "Environment" = "Development"
  }
}

resource "null_resource" "delay_between_bastion_and_master" {
  provisioner "local-exec" {
    command = "sleep 90" # Sleep for 1 minute
  }
  depends_on = [aws_instance.bastion]
}

resource "aws_instance" "master-server" {
  ami                  = var.instance_ami_type
  instance_type        = var.instance_type_master
  key_name             = "testing-dev-1"
  subnet_id            = aws_subnet.dev_subnet_public_1.id
  iam_instance_profile = data.aws_iam_instance_profile.s3-access-profile.name
  vpc_security_group_ids = [
    aws_security_group.ssh.id,
    aws_security_group.web-traffic.id
  ]
  user_data = file("user-managed-script.sh")

  tags = {
    "Name"        = "master"
    "Environment" = "Production"
  }
  depends_on = [null_resource.delay_between_bastion_and_master]
}

resource "aws_instance" "load-balancer-server" {
  ami                  = var.instance_ami_type
  instance_type        = var.instance_type_lb
  key_name             = "testing-dev-1"
  subnet_id            = aws_subnet.dev_subnet_public_1.id
  iam_instance_profile = data.aws_iam_instance_profile.s3-access-profile.name
  vpc_security_group_ids = [
    aws_security_group.ssh.id,
    aws_security_group.web-traffic.id
  ]
  user_data = file("lb-managed.sh")

  tags = {
    "Name"        = "loadbalancer"
    "Environment" = "Production"
  }
}
