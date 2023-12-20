// Create ECR private docker hub

resource "aws_ecr_repository" "dokcer-private-hub" {
	  name = "dokcer-private-hub"
	

	  image_scanning_configuration {
	    scan_on_push = true
	  }
}

// 가장 최근 버전만 보관하기

