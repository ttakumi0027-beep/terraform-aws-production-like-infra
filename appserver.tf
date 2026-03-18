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
# EC2 for Appserver
# ------------------------

