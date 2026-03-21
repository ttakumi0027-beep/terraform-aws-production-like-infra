# ------------------------
# key pair
# ------------------------
# resource "aws_key_pair" "kaypair" {
#   key_name   = "${var.project}-${var.environment}-keypair"
#   public_key = file("./source/portfolio-dev-keypair.pub")

#   tags = {
#     Name    = "${var.project}-${var.environment}-keypair"
#     Project = var.project
#     Env     = var.environment
#   }
# }

# ------------------------
# EC2 for Application-server
# ------------------------


# 検証用に作成、ASG作成の際に削除予定
# resource "aws_instance" "app_server" {
#   ami                         = data.aws_ami.app.id
#   instance_type               = "t3.micro"
#   subnet_id                   = aws_subnet.app_private_subnet_1a.id
#   associate_public_ip_address = false
#   iam_instance_profile        = aws_iam_instance_profile.ec2_ssm_profile.name
#   key_name                    = aws_key_pair.kaypair.key_name

#   tags = {
#     Name    = "${var.project}-${var.environment}-app-server"
#     Project = var.project
#     Env     = var.environment
#   }
# }


# ------------------------
# Launch Template
# ------------------------
resource "aws_launch_template" "app_lt" {
  name                   = "${var.project}-${var.environment}-app-lt"
  update_default_version = true

  image_id      = data.aws_ami.app.id
  instance_type = "t3.micro"

  vpc_security_group_ids = [
    aws_security_group.app_sg.id
  ]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_ssm_profile.name
  }

  user_data = filebase64("./source/initialize.sh")

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name    = "${var.project}-${var.environment}-app-server"
      Project = var.project
      Env     = var.environment
      Type    = "app"
    }
  }

  tags = {
    Name    = "${var.project}-${var.environment}-app-lt"
    Project = var.project
    Env     = var.environment
  }
}