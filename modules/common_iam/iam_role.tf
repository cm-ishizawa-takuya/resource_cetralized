data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "instance_ssm_role" {
  name               = "${var.system_id}-iamrole-instance-ssm"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  ]
}

resource "aws_iam_instance_profile" "instance_ssm_role" {
  name = "${var.system_id}-instance-profile-instance-ssm"
  role = aws_iam_role.instance_ssm_role.name
}