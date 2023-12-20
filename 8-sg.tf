# Security Group 생성 (5ea)
# External ALB 보안 그룹 생성
resource "aws_security_group" "external-alb-sg" {
  name = "external-alb-sg"
  description = "Internet facing ALB SG"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/32"]
  }

  egress { # 보안 그룹 생성 시, Outbound 허용을 직접 지정해줘야 통신 가능(관리 콘솔은 자동 생성 / 테라폼은 지정 필수)
    from_port = 0
    to_port = 0
    protocol = "-1" # Protocol -1은 전체 프로토콜을 의미
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "external-alb-sg"
  }
}

# Web Tier Instance 보안 그룹 생성
resource "aws_security_group" "web-tier-instance-sg" {
  name = "web-tier-instance-sg"
  description = "web instance sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/32"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = [aws_security_group.external-alb-sg.id]
    # 처음에 생성한 External ALB SG를 Inbound로 허용하도록 구성
  }

  egress { # 보안 그룹 생성 시, Outbound 허용을 직접 지정해줘야 통신 가능(관리 콘솔은 자동 생성 / 테라폼은 지정 필수)
    from_port = 0
    to_port = 0
    protocol = "-1" # Protocol -1은 전체 프로토콜을 의미
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "web-tier-instance-sg"
  }
}

# Internal ALB 보안 그룹 생성
resource "aws_security_group" "internal-alb-sg" {
  name = "internal-alb-sg"
  description = "Internal ALB Between Web-App"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = [aws_security_group.web-tier-instance-sg.id]
    # web-tier-instance-sg에서 인바운드 되는 트래픽 허용
  }

  egress { # 보안 그룹 생성 시, Outbound 허용을 직접 지정해줘야 통신 가능(관리 콘솔은 자동 생성 / 테라폼은 지정 필수)
    from_port = 0
    to_port = 0
    protocol = "-1" # Protocol -1은 전체 프로토콜을 의미
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "internal-alb-sg"
  }
}

# Private Instance(App Instance) 보안 그룹 생성
resource "aws_security_group" "private-instance-sg" {
  name = "private-instance-sg"
  description = "App tier instance sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 4000
    to_port = 4000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 4000
    to_port = 4000
    protocol = "tcp"
    security_groups = [aws_security_group.internal-alb-sg.id]
    # 내부 ALB SG와 전체 주소 허용이 된, 4000TCP 포트로 트래픽 수신 설정
    # 해당 4000번 포트는 ALB LB Target Group Register Port로 설정 사항에 따라 변동 가능
  }

  egress { # 보안 그룹 생성 시, Outbound 허용을 직접 지정해줘야 통신 가능(관리 콘솔은 자동 생성 / 테라폼은 지정 필수)
    from_port = 0
    to_port = 0
    protocol = "-1" # Protocol -1은 전체 프로토콜을 의미
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "private-instance-sg"
  }  
}
