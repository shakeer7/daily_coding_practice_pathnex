provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "PathnexSG" {
  name   = "pathnex-sg"
  vpc_id = aws_vpc.PathnexVPC.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Pathnex-SG"
  }
}

resource "aws_instance" "PathnexEC2" {
  ami           = "ami-0abcd1234abcd1234"
  instance_type = "c6a.12xlarge"

  user_data = <<EOF



resource "aws_vpc" "PathnexVPC" {
  cidr_block = "10.10.0.0/16"

  tags = {
    Name = "Pathnex-VPC"
  }
}

resource "aws_subnet" "PathnexSubnet" {
  vpc_id                  = aws_vpc.PathnexVPC.id
  cidr_block              = "10.10.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Pathnex-Subnet"
  }
}

resource "aws_internet_gateway" "PathnexIGW" {
  vpc_id = aws_vpc.PathnexVPC.id

  tags = {
    Name = "Pathnex-IGW"
  }
}

resource "aws_route_table" "PathnexRT" {
  vpc_id = aws_vpc.PathnexVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.PathnexIGW.id
  }

  tags = {
    Name = "Pathnex-RouteTable"
  }
}

resource "aws_route_table_association" "PathnexRTA" {
  subnet_id      = aws_subnet.PathnexSubnet.id
  route_table_id = aws_route_table.PathnexRT.id
}

resource "aws_key_pair" "PathnexKey" {
  key_name   = "PathnexKey"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_eip" "PathnexEIP" {
  instance = aws_instance.PathnexEC2.id

  tags = {
    Name = "Pathnex-EIP"
  }
}

resource "aws_ebs_volume" "PathnexVolume" {
  availability_zone = "us-east-1a"
  size              = 20

  tags = {
    Name = "Pathnex-Volume"
  }
}

resource "aws_volume_attachment" "PathnexAttach" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.PathnexVolume.id
  instance_id = aws_instance.PathnexEC2.id
}

resource "aws_s3_bucket" "PathnexBucket" {
  bucket = "pathnex-devops-bucket"

  tags = {
    Name = "PathnexBucket"
  }
}

resource "aws_lb" "PathnexALB" {
  name               = "pathnex-alb"
  load_balancer_type = "application"
  subnets            = [aws_subnet.PathnexSubnet.id]

  tags = {
    Name = "Pathnex-ALB"
  }
}

resource "aws_lb_listener" "PathnexListener" {
  load_balancer_arn = aws_lb.PathnexALB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Pathnex ALB Running"
      status_code  = "200"
    }
  }
}

resource "aws_route53_record" "PathnexRecord" {
  zone_id = "Z1234567890"
  name    = "app.pathnex.com"
  type    = "A"
  ttl     = 300
  records = [aws_eip.PathnexEIP.public_ip]
}

resource "aws_db_instance" "PathnexRDS" {
  allocated_storage      = 20
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  username               = "admin"
  password               = "Pathnex123"
  skip_final_snapshot    = true
}

resource "aws_dynamodb_table" "PathnexTable" {
  name           = "PathnexTrainingTable"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "ID"

  attribute {
    name = "ID"
    type = "S"
  }

  tags = {
    Name = "Pathnex-DDB"
  }
}

output "PathnexPublicIP" {
  value = aws_instance.PathnexServer.public_ip
}

output "Pathnex_Key_Name" {
  value = aws_key_pair.PathnexKey.key_name
}

resource "aws_instance" "PathnexServer" {
  ami           = "ami-0abcd1234abcd1234"
  instance_type = "r5.2xlarge"

  tags = {
    Name = "Pathnex-Output-EC2"
  }
}

resource aws_instance "Bad" {
 ami "ami-123"
 instance_type c6i.8xlarge
}

resource "aws_s3" "BadBucket" {
bucket = pathnex-bucket
acl public-read
}

