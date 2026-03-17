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
# IAM Role
# ------------------------