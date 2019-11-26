resource "aws_iam_user" "snowflake-user" {
  name = "snowflake-user"
}

resource "aws_iam_access_key" "snowflake-user" {
  user = "${aws_iam_user.snowflake-user.name}"
}

resource "aws_iam_user_policy" "snowflake-user-policy" {
  name = "test"
  user = "${aws_iam_user.snowflake-user.name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "s3:PutObject",
              "s3:GetObject",
              "s3:GetObjectVersion"
            ],
            "Resource": "arn:aws:s3:::<bucket>/<prefix>/*"
        },
        {
            "Effect": "Allow",
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::<bucket>",
            "Condition": {
                "StringLike": {
                    "s3:prefix": [
                        "*"
                    ]
                }
            }
        }
    ]
}
EOF
}