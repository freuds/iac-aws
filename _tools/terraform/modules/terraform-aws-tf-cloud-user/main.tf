resource "aws_iam_user" "tf-cloud" {
  name = "${var.env}-tf-cloud-iam-user"
}

resource "aws_iam_access_key" "tf-cloud" {
  user = aws_iam_user.tf-cloud.name
}

resource "aws_iam_user_policy_attachment" "tf-cloud" {
  user       = aws_iam_user.tf-cloud.name
  policy_arn = var.tf_cloud_policy_arn
}