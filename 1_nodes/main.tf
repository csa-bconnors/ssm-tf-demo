/*
  CSA - SSM Demo
  Spins up nodes for SSM to play with
*/

# Create EC2 Instances
variable "pool_nodes" {
  type = list(string)
  default = [
    "a",
    # "b",
    # "c",
    # "d",
    # "e",
    # "f"
  ]
}

resource "aws_instance" "pool_test_nodes" {
  for_each = toset(var.pool_nodes)

  ami                  = "ami-0ded330691a314693"
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name

  tags = {
    "Name"        = "linux_test_${each.value}"
    "Environment" = "test"
    "Patch Group" = "test-amazon-linux"
  }

}

resource "aws_instance" "pool_prod_nodes" {
  for_each = toset(var.pool_nodes)

  ami                  = "ami-0ded330691a314693"
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name

  tags = {
    "Name"        = "linux_prod_${each.value}"
    "Environment" = "prod"
    "Patch Group" = "prod-amazon-linux"
  }

}

# SSM EC2 Instance Profile
data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "policy-attachment" {
  role       = aws_iam_role.ssm_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role" "ssm_instance_role" {
  name               = "SSMManagedInstance"
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "SSMManagedInstance"
  role = aws_iam_role.ssm_instance_role.name
}
