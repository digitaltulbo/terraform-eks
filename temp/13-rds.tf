// Create rds_db Security group

resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Security group for RDS instance"
  vpc_id      = aws_vpc.smpVPC.id

  ingress {
    from_port   = 3306  # Adjust based on your database engine and configuration
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # Replace with your IP or range for secure access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds_sg"
  }
}

// Create RDS subnet a,c

resource "aws_subnet" "rds_subnet_a" {
  vpc_id     = aws_vpc.VPC.id
  cidr_block = "10.0.7.0/24"
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "RDS a"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/devlink" = "owned"
  }
}

resource "aws_subnet" "rds_subnet_c" {
  vpc_id     = aws_vpc.VPC.id
  cidr_block = "10.0.8.0/24"
  availability_zone = "ap-northeast-2c"
  tags = {
    Name = "RDS c"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/devlink" = "owned"
  }
}

//Create RDS instance 

resource "aws_db_instance" "primary_rds_instance" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0.33"
  instance_class       = "db.t2.micro" 
  db_name              = "primary_db"
  username             = "myuser"
  password             = "mypassword"
  parameter_group_name = "default.mysql8.0"
  db_subnet_group_name = aws_db_subnet_group.primary_rds_subnet_group.name

  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  backup_retention_period = 7 
  skip_final_snapshot     = true 

  tags = {
    Name = "FreeTierPrimaryRDSInstance"
  }
}

// Create rds subnet group

resource "aws_db_subnet_group" "primary_rds_subnet_group" {
  name       = "my-primary-rds-subnet-group"
  subnet_ids = [aws_subnet.rds_subnet_a.id, aws_subnet.rds_subnet_c.id]

  tags = {
    Name = "My Primary RDS Subnet Group"
  }
}

// Create rds read replicas
resource "aws_db_instance" "read_replica" {
  identifier          = "my-rds-replica"
  replicate_source_db = aws_db_instance.primary_rds_instance.id
  instance_class      = "db.t2.micro"
  skip_final_snapshot     = true  
  tags = {
    Name = "MyRDSReadReplica"
  }
}

resource "aws_db_subnet_group" "replica_subnet_group" {
  name       = "my-replica-rds-subnet-group"
  subnet_ids = [aws_subnet.rds_subnet_a.id, aws_subnet.rds_subnet_c.id]

  tags = {
    Name = "My Replica RDS Subnet Group"
  }
}


## Create RDS Route table
resource "aws_route_table" "db-rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "db-rt"
  }
}
// Define route for db route table
resource "aws_route" "db-route" {
  route_table_id         = aws_route_table.db-rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

## Create route table associtation
resource "aws_route_table_association" "rds_a" {
  subnet_id      = aws_subnet.rds_subnet_a.id
  route_table_id = aws_route_table.db-rt.id
}

resource "aws_route_table_association" "rds_c" {
  subnet_id      = aws_subnet.rds_subnet_c.id
  route_table_id = aws_route_table.db-rt.id
}