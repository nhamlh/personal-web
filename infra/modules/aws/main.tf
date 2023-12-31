
resource "aws_instance" "this" {
  ami                    = "ami-0d96ec8a788679eb2" # ubuntu 22.04 TLS
  instance_type          = "t3.small"
  key_name               = aws_key_pair.owner.key_name
  vpc_security_group_ids = [aws_security_group.this.id]

  tags = {
    Name = "my_linux_box"
  }
}

resource "aws_eip" "this" {
  domain   = "vpc"
  instance = aws_instance.this.id
}

resource "aws_key_pair" "owner" {
  key_name   = "owner"
  public_key = var.ec2_public_key
}

resource "aws_security_group" "this" {
  name        = "my_linux_box"
  description = "allow http and mail ports"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = toset([22, 80, 443, 8080, 25, 587, 465, 143, 993, 4190])
    content {
      description = "http"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "my_linux_box"
  }
}

output "public_ip" {
  value = aws_aws_eip.public_ip
}
