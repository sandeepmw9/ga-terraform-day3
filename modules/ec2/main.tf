#defines ec2 module

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "ec2_instance" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_id
  associate_public_ip_address = true
  key_name = aws_key_pair.key.key_name
  security_groups = [aws_security_group.test_sg.id]

  tags = {
    Name      = var.instance_name
    terraform = true
  }

  connection {
    user        = "ubuntu"
    private_key = tls_private_key.key.private_key_pem
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [ 
      "sudo apt update -y",
      "sudo apt install nginx -y",
      "echo 'hello from terraform provisioned instance' > /usr/share/nginx/index.html",
      "sudo service nginx restart"
     ]
  }

}


resource "tls_private_key" "key" {
  algorithm = "RSA"
}

# resource "local_file" "public_key" {
#   filename = "id_rsa.pub"
#   content  = tls_private_key.key.public_key_openssh
# }

resource "local_file" "private_key" {
  filename = "id_rsa.pem"
  content  = tls_private_key.key.private_key_pem

  # provisioner "local-exec" {
  #   command = "chmod 600 id_rsa.pem"
  # }
}

resource "aws_key_pair" "key" {
  key_name = "id_rsa"
  public_key = tls_private_key.key.public_key_openssh
}


resource "aws_security_group" "test_sg" {
  name        = "test_sg-${terraform.workspace}"
  vpc_id      = var.vpc_id
  description = "Web Traffic"
  ingress {
    description = "Allow Port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow Port 443"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow Port 22"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all ip and ports outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
