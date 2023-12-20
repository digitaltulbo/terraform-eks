# IAM Role 생성
resource "aws_iam_role" "eks_devlink_cluster" {
    name = "eks_devlink_cluster"

    assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
          "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY  
}
# 위에서 생성한 IAM Role에 EKS Cluster Policy 추가
resource "aws_iam_role_policy_attachment" "devlink-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_devlink_cluster.name
}
# 위에서 생성한 IAM Role에 리소스 컨트롤 Policy 추가
resource "aws_iam_role_policy_attachment" "terraform-eks-cluster-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_devlink_cluster.name
}
# Security Group 생성
resource "aws_security_group" "devlink-cluster" {
  name        = "devlink-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devlink-cluster"
  }
}



resource "aws_eks_cluster" "devlink" {
  name     = "devlink"
  role_arn = aws_iam_role.eks_devlink_cluster.arn
    
  vpc_config {
    subnet_ids = [
        aws_subnet.private_subnet_a.id,
        aws_subnet.private_subnet_c.id,
    ]
  }
  
  depends_on = [ 
    aws_iam_role_policy_attachment.devlink-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.terraform-eks-cluster-AmazonEKSVPCResourceController 
  ] 
}