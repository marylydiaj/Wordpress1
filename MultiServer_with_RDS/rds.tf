resource "aws_db_instance" "tfrds" {
allocated_storage = "10"
storage_type = "gp2"
engine = "mysql"
engine_version = "5.7"
instance_class = "db.t2.micro"
name = "zippyops"
username = "zippyops"
password = "zippyops"
availability_zone = "us-east-1a"
backup_retention_period = "7"
backup_window = "00:05-00:35"
skip_final_snapshot = true

db_subnet_group_name = aws_db_subnet_group.tfdbsubnetgroup.id
vpc_security_group_ids = [aws_security_group.dbsg.id]

  provisioner "local-exec" {
    command = "echo ${aws_db_instance.tfrds.address} >> /var/lib/jenkins/workspace/Wordpress/endpoint"
}
}

output "rds_link" {
  description = "The address of the RDS Instnce"
  value = aws_db_instance.tfrds.address
}

#############################################################################

resource "aws_eip" "nat" {
vpc = true
}


resource "aws_subnet" "tfprivatesubnet" {
         vpc_id = aws_vpc.tfvpc.id
         cidr_block = "192.2.3.0/24"
         availability_zone = "us-east-1b"
tags = {
        Name = "TerraformSubnets"
     }
                                         }

resource "aws_subnet" "tfpublicsubnet2" {
         vpc_id = aws_vpc.tfvpc.id
         cidr_block = "192.2.4.0/24"
         availability_zone = "us-east-1c"
tags = {
        Name = "TerraformSubnets"
     }
}

resource "aws_db_subnet_group" "tfdbsubnetgroup" {
name = "rdssg"
subnet_ids = [aws_subnet.tfprivatesubnet.id, aws_subnet.tfpublicsubnet.id, aws_subnet.tfpublicsubnet2.id] 

tags = {
       Name = "rdssubnetgrp"
     }
}

resource "aws_nat_gateway" "ngw"{
allocation_id = aws_eip.nat.id
subnet_id = aws_subnet.tfprivatesubnet.id

tags = {
       Name = "NatGatewaytf"
     }
}
resource "aws_route_table_association" "tfprivate" {
subnet_id = aws_subnet.tfprivatesubnet.id
route_table_id = aws_route_table.tfprivate.id

}
resource "aws_route_table" "tfprivate" {
vpc_id = aws_vpc.tfvpc.id

route{
cidr_block = "0.0.0.0/0"
nat_gateway_id = aws_nat_gateway.ngw.id

}
tags = {
       Name = "Privateroute"
}
}
############################################################################

resource "aws_security_group" "dbsg"{
vpc_id = aws_vpc.tfvpc.id
ingress {
       protocol = "tcp"
       from_port = "3306"
       to_port = "3306"
       security_groups = [aws_security_group.tfsecuritygroup.id]
        }

egress {
      protocol = "tcp"
      from_port = "3306"
      to_port = "3306"
      security_groups = [aws_security_group.tfsecuritygroup.id]
}
tags = {
      Name = "dbsecuritygroup"
     }

}

