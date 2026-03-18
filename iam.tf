# ------------------------
# IAM Group
# ------------------------

resource "aws_iam_group" "admin" {
  name = "Admin"
}

resource "aws_iam_group" "engineer" {
  name = "Engineer"
}

resource "aws_iam_group" "operator" {
  name = "Operator"
}

resource "aws_iam_group_policy_attachment" "admin_attach" {
  group      = aws_iam_group.admin.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_group_policy_attachment" "engineer_attach" {
  group      = aws_iam_group.engineer.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

resource "aws_iam_group_policy_attachment" "operator_attach" {
  group      = aws_iam_group.operator.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}


# ------------------------
# IAM Users
# ------------------------

resource "aws_iam_user" "users" {
  for_each = var.iam_users

  name = each.key
}

resource "aws_iam_user_group_membership" "memberships" {
  for_each = var.iam_users

  user   = aws_iam_user.users[each.key].name
  groups = each.value.groups
}

# ------------------------
# EC2 Assume Role Policy
# ------------------------

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# ------------------------
# IAM Role for SSM
# ------------------------
resource "aws_iam_role" "ec2_ssm_role" {
  name               = "${var.project}-${var.environment}-ec2-ssm-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Name    = "${var.project}-${var.environment}-ec2-ssm-role"
    Project = var.project
    Env     = var.environment
  }
}

# ------------------------
# Instance Profile
# ------------------------
resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "${var.project}-${var.environment}-ec2-ssm-profile"
  role = aws_iam_role.ec2_ssm_role.name

  tags = {
    Name    = "${var.project}-${var.environment}-ec2-ssm-profile"
    Project = var.project
    Env     = var.environment
  }
}

# ------------------------
# role policy
# ------------------------
resource "aws_iam_role_policy_attachment" "ec2_ssm_profile" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
