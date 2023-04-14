output "common_instance_profile_name" {
  value = aws_iam_instance_profile.instance_ssm_role.name
}