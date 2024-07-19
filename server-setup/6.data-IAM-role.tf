data "aws_iam_instance_profile" "s3-access-profile" {
  name = "s3-bucket-access-via-instance" # This should match the name of your IAM role
}
