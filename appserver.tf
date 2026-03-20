# ------------------------
# key pair
# ------------------------
resource "aws_key_pair" "kaypair" {
  key_name   = "${var.project}-${var.environment}-keypair"
  public_key = file("./source/portfolio-dev-keypair.pub")

  tags = {
    Name    = "${var.project}-${var.environment}-keypair"
    Project = var.project
    Env     = var.environment
  }
}

# ------------------------
# EC2 for Application-server
# ------------------------


# 検証用に作成、ASG作成の際に削除予定
resource "aws_instance" "app_server" {
  ami                         = data.aws_ami.app.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.app_private_subnet_1a.id
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.ec2_ssm_profile.name
  key_name                    = aws_key_pair.kaypair.key_name

  tags = {
    Name    = "${var.project}-${var.environment}-app-server"
    Project = var.project
    Env     = var.environment
  }
}

