resource "aws_vpc" "dev" {
    cidr_block = "10.0.0.0/16"
    tags = {
      Name = "custom vpc"
    }
  
}

resource "aws_subnet" "public" {
    cidr_block = "10.0.0.0/24"
    vpc_id = aws_vpc.dev.id
    availability_zone = "ap-south-1a"
    tags = {
      Name = "Public subnet"
    
    }
  
}

resource "aws_subnet" "Private" {
    vpc_id = aws_vpc.dev.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "ap-south-1b"

  
}

resource "aws_internet_gateway" "dev" {
    vpc_id = aws_vpc.dev.id
  
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.dev.id
    route {
        cidr_block= "0.0.0.0/0"
        gateway_id = aws_internet_gateway.dev.id
    
    }
}
resource "aws_route_table_association" "public" {
    route_table_id = aws_route_table.public.id
    subnet_id = aws_subnet.public.id
  
}
resource "aws_eip" "name" {
    domain = "vpc"
  
}
resource "aws_nat_gateway" "name" {
    allocation_id = aws_eip.name.id
    subnet_id = aws_subnet.public.id
  
}

resource "aws_route_table" "private" {
    vpc_id = aws_vpc.dev.id
    route {
        cidr_block= "0.0.0.0/0"
        gateway_id = aws_nat_gateway.name.id
    
    }

  
}
resource "aws_route_table_association" "name" {
    subnet_id = aws_subnet.Private.id
    route_table_id = aws_route_table.private.id 
  
}
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  vpc_id      = aws_vpc.dev.id
  tags = {
    Name = "dev_sg"
  }
 ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }
ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }
egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }


  }
 
  resource "aws_instance" "instance" {
    ami = "ami-0f1dcc636b69a6438"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.public.id
    associate_public_ip_address = true
    vpc_security_group_ids = [ aws_security_group.allow_tls.id ]
    key_name = "mum-key"
    
  }