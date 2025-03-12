provider "aws" {
  region     = "us-west-2"
  access_key = "######################"
  secret_key = "######################################"
}

resource "aws_key_pair" "deployer" {
  key_name   = "dev"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC3Fz3kINwrMNMVad4ee0dhBtNqVvHVTEkbUAOp54yMbOicwN24Xvt/O7U1jwKGXcPADsmX6+pFw44b+k9kvLRklRuJ0yMU2+RUTlyLDtUoLWE/wZe5r0Sd1yZqSLvHaxYgXbBnZ0TCHfOtaaXDSLR/xi6XU4Xw9OwWyNaNPINjuYiMEJoZI8Um87c/o9BA3TQpYTV2QveHW1KSx3jM9fNyfx4uuuVo1Tyft1QXnrR9EQ96pzWJTilOGiWW9iy/48uLlWr6NoFE9g1/31CoKpn+ddx9S+xPGE+IC33/z2MJAkM17PgEzcMnbjrTbfRz0Y0h5Ce3BrFqLdkZSt4j+XhNiHJ5m2l8tExzWPClX7kOzMi1y54UzxteEPiJalGrCfYXSDPAR7sysKOR97moCbE0Z84KkLEoIhImAfiJ4TgvHn1a3YIV8LspfEbJzYdpFe1TJneNQOTv2LHoh1v8d3jf31URn3CfxhMaW8AdsuZoPuIzLLNA7k/6LLgbwbx05Fk= root@ip-172-31-20-183.us-west-2.compute.internal"
}

variable "private-key" {
  default = "dev"
}

# attache the default VPC
resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

# Create a Security Group for instance access
resource "aws_security_group" "terraform_sg" {
  name        = "terraform-sg"
  description = "Allow SSH and HTTP inbound traffic, all outbound traffic"
  vpc_id      = aws_default_vpc.default.id

  tags = {
    Name = "terraform-sg"
  }
}

# Allow SSH (port 22) access from anywhere
resource "aws_security_group_rule" "allow_ssh" {
  security_group_id = aws_security_group.terraform_sg.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Allow HTTP (port 80) access from anywhere
resource "aws_security_group_rule" "allow_http" {
  security_group_id = aws_security_group.terraform_sg.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_instance" "web" {
  ami           = "ami-00c257e12d6828491"
  instance_type = "t2.micro"
  key_name     = "dev"
  security_groups = [aws_security_group.terraform_sg.name]
  tags = {
    Name = "HelloWorld"
  }

  connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = file("./dev")
    host     = self.public_ip
  }  
  provisioner "remote-exec" {
    inline = [
      "echo 'build ssh connection' ",
    ]
  }  
provisioner "local-exec" {
  command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${aws_instance.web.public_ip}, --private-key ${var.private-key} -u ubuntu play.yml"
}
}

output "web_ip" {
   value = aws_instance.web.public_ip
}
