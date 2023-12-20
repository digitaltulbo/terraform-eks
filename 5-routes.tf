// Create Web route table
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.main.id
    
route {
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
  }
    tags = {
    Name = "public-rt"
  }
}

// Create App Route table
resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-rt"
  }
}

//Create route table associtation
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "public_c" {
  subnet_id      = aws_subnet.public_subnet_c.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_route_table_association" "private_c" {
  subnet_id      = aws_subnet.private_subnet_c.id
  route_table_id = aws_route_table.private-rt.id
}

