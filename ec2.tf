resource "aws_security_group" "websg" {
    name = "vpc_web"
    description = "Allow incoming HTTP connections."
    vpc_id = aws_vpc.customvpc.id

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
       from_port   = 8000
       to_port     = 8000
       protocol    = "tcp"
       cidr_blocks = ["0.0.0.0/0"]
  }
   egress {
       from_port   = 8000
       to_port     = 8000
       protocol    = "tcp"
       cidr_blocks = ["0.0.0.0/0"]
   }
   ingress {
       from_port   = 3306
       to_port     = 3306
       protocol    = "tcp"
       cidr_blocks = ["0.0.0.0/0"]
  }
   egress {
       from_port   = 3306
       to_port     = 3306
       protocol    = "tcp"
       cidr_blocks = ["0.0.0.0/0"]
   }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "WebSG"
        Terraform = true
    }
}

resource "aws_instance" "web1" {
    ami = var.image
    availability_zone = "us-east-1a"
    instance_type = var.instance_type
    key_name = var.key
    user_data = data.template_file.web1.rendered
    vpc_security_group_ids = [aws_security_group.websg.id]
    subnet_id = aws_subnet.us-east-1a-public.id
    private_ip = var.publicec2_ip
    associate_public_ip_address = true
    source_dest_check = false
    root_block_device {
       volume_type           = "gp2"
       volume_size           = "10"
       delete_on_termination = "true"
    }
    tags = {
        Name = "WebServer"
        Terraform = true
    }
    provisioner "local-exec" {
         command = "echo ${aws_instance.web1.public_ip} >> /var/lib/jenkins/workspace/Wordpress1/publicip"
    }
     provisioner "local-exec" {
         command = "echo ${aws_instance.web1.private_ip} >> /var/lib/jenkins/workspace/Wordpress1/privateip"
    }
}
data "template_file" "web1" {
  template = file("install.sh")
}

#resource "aws_eip" "web1" {
#    instance = aws_instance.web1.id
#    vpc = true
#}
#resource "aws_network_interface" "web1" {
#  subnet_id       = aws_subnet.us-east-1a-public.id
#  private_ips     = ["10.0.0.11"]
#  security_groups = [aws_security_group.websg.id]
#}


