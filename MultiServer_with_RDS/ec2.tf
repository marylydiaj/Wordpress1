resource "aws_vpc" "tfvpc" {
         cidr_block = "192.2.0.0/16"
enable_dns_hostnames = "true"
tags =  {
         Name = "Terraform"
     }
                             }

resource "aws_subnet" "tfpublicsubnet" {
        vpc_id = aws_vpc.tfvpc.id
        cidr_block = "192.2.2.0/24"
        availability_zone = "us-east-1a"
tags = {
        Name = "TerraformSubnets"
     }
                                  }

#############################################################################
resource "aws_instance" "FirsttfInstance" {
ami = var.image
instance_type = var.instance_type
subnet_id = aws_subnet.tfpublicsubnet.id
private_ip = var.privateec2_ip
key_name = var.key
user_data = data.template_file.FirsttfInstance.rendered
get_password_data = "false"
availability_zone = "us-east-1a"
security_groups = [aws_security_group.tfsecuritygroup.id]
associate_public_ip_address = true
root_block_device {
       volume_type           = "gp2"
       volume_size           = "10"
       delete_on_termination = "true"
}
tags =  {
       Name = "TerraformInstance"
     }
provisioner "local-exec" {
    command = "echo ${aws_instance.FirsttfInstance.public_ip} >> /var/lib/jenkins/workspace/Wordpress/publicip"
}
}
data "template_file" "FirsttfInstance" {
  template = file("install.sh")
}
##################################################################################

resource "aws_internet_gateway" "tfgw"{
vpc_id = aws_vpc.tfvpc.id

tags = {
       Name = "tfgateway"
     }
}
resource "aws_route_table_association" "tf" {
subnet_id = aws_subnet.tfpublicsubnet.id
route_table_id = aws_route_table.tf.id
}
resource "aws_route_table" "tf" {
vpc_id = aws_vpc.tfvpc.id

route{
cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.tfgw.id
}

tags = {
       Name = "Publicroute"

}
}

###############################################################################
resource "aws_security_group" "tfsecuritygroup" {
vpc_id = aws_vpc.tfvpc.id
ingress {
      protocol = "tcp"
      self = true
      from_port = 22
      to_port = 22
      cidr_blocks = ["0.0.0.0/0"]
         }

egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      }

ingress {
      protocol = "tcp"
      self  = true
      from_port = 80
      to_port = 80 
      cidr_blocks = ["0.0.0.0/0"]
        }

ingress {
      protocol = "tcp"
      self  = true
      from_port = 8000
      to_port = 8000
      cidr_blocks = ["0.0.0.0/0"]
        }
egress {
      protocol = "tcp"
      self  = true
      from_port = 8000
      to_port = 8000
      cidr_blocks = ["0.0.0.0/0"]
        }
ingress {
      protocol = "tcp"
      self  = true
      from_port = 3306
      to_port = 3306
      cidr_blocks = ["0.0.0.0/0"]
        }
egress {
      protocol = "tcp"
      self  = true
      from_port = 3306
      to_port = 3306
      cidr_blocks = ["0.0.0.0/0"]
        }
tags = {
       Name = "tfsecuritygroup"
     }

}
