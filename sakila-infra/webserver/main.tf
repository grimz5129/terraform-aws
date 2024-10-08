#############################
## Creating the web server ##
#############################

#Creating an internet gateway
resource "aws_internet_gateway" "java10x_sakila_yvelasquez_igw_tf" {
  vpc_id = var.var_vpc_id_tf

  tags = {
    Name = "java10x_sakila_yvelasquez_igw"
  }
}

#Creating a routing table
resource "aws_route_table" "java10x_sakila_yvelasquez_rt_public_tf" {
  vpc_id = var.var_vpc_id_tf

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.java10x_sakila_yvelasquez_igw_tf.id
  }

  tags = {
    Name = "java10x_sakila_yvelasquez_rt_public"
  }
}

#Creating a subent for the web server
resource "aws_subnet" "java10x_sakila_yvelasquez_subnet_public_tf" {
  vpc_id = var.var_vpc_id_tf
  cidr_block = "10.117.1.0/24"

  tags = {
    Name = "java10x_sakila_yvelasquez_subnet_public"
  }
}

#Creating a route table association
resource "aws_route_table_association" "java10x_sakila_yvelasquez_rt_assoc_tf" {
  subnet_id = aws_subnet.java10x_sakila_yvelasquez_subnet_public_tf.id
  route_table_id = aws_route_table.java10x_sakila_yvelasquez_rt_public_tf.id
}

#Creating a nacl
resource "aws_network_acl" "java10x_sakila_yvelasquez_nacl_public_tf" {
  vpc_id = var.var_vpc_id_tf

  #ingress means inbound
  ingress {
    protocol = "tcp"
    rule_no = 100
    action = "allow"
    cidr_block = "94.13.81.61/32"
    from_port = 22
    to_port = 22
  }

  ingress {
    protocol = "tcp"
    rule_no = 200
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 8080
    to_port = 8080
  }

  ingress {
    protocol = "tcp"
    rule_no = 300
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 1024
    to_port = 65535
  }

#egress means outbound
  egress {
    protocol = "tcp"
    rule_no = 100
    action = "allow"
    cidr_block = "10.117.2.0/24"
    from_port = 3306
    to_port = 3306
  }

  egress {
    protocol = "tcp"
    rule_no = 200
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 443
    to_port = 443
  }

  egress {
    protocol = "tcp"
    rule_no = 300
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 80
    to_port = 80
  }

  egress {
    protocol = "tcp"
    rule_no = 1000
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 1024
    to_port = 65535
  }

  #You can add more subnets connected to the same nacl, using commas to speperate
  subnet_ids = [aws_subnet.java10x_sakila_yvelasquez_subnet_public_tf.id]

  tags = {
    Name = "java10x_sakila_yvelasquez_nacl_public"
  }
}

#Creating a secuirty group
resource "aws_security_group" "java10x_sakila_yvelasquez_sg_web_tf" {
  name = "java10x_sakila_yvelasquez_sg_web"
  vpc_id = var.var_vpc_id_tf

  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = ["94.13.81.61/32"]
  }

  ingress {
    protocol = "tcp"
    from_port = 8080
    to_port = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol = "tcp"
    from_port = 3306
    to_port = 3306
    cidr_blocks = ["10.117.2.0/24"]
  }

  egress {
    protocol = "tcp"
    from_port = 80
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol = "tcp"
    from_port = 443
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "java10x_sakila_yvelasquez_sg_web"
  }
}


#Creating aws instance
resource "aws_instance" "java10x_sakila_yvelasquez_server_web_tf" {
  ami = var.var_ami_linux_ubuntu_tf
  instance_type = "t2.micro"
  key_name = "cyber-10x-yvelasquez"

  subnet_id = aws_subnet.java10x_sakila_yvelasquez_subnet_public_tf.id
  vpc_security_group_ids = [aws_security_group.java10x_sakila_yvelasquez_sg_web_tf.id]
  associate_public_ip_address = true

  #depends_on = [aws_instance.java10x_sakila_yvelasquez_server_database_tf]

  #creating ssh connection
  connection {
    type = "ssh"
    host = self.public_ip
    user = "ubuntu"
    #private key location
    private_key = file(var.var_private_key_location_tf)
  }

  provisioner "file" {
    source = "./init-scripts/docker-install.sh"
    destination = "/home/ubuntu/docker-install.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 744 /home/ubuntu/docker-install.sh",
      "/home/ubuntu/docker-install.sh",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "docker run hello-world",
    ]
  }

  provisioner "file" {
    source = "./init-scripts/application.properties"
    destination = "/home/ubuntu/application.properties"
  }

  provisioner "file" {
    source = "./init-scripts/docker-run.sh"
    destination = "/home/ubuntu/docker-run.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 744 /home/ubuntu/docker-run.sh",
      "chmod 400 /home/ubuntu/application.properties",
      "/home/ubuntu/docker-run.sh",
    ]
  }

  tags = {
    Name = "java10x_sakila_yvelasquez_server_web"
  }
}

resource "aws_route53_record" "java10x_sakila_yvelasquez_r53_record_app_tf" {
    zone_id = var.var_zone_id_tf
    name = "www"
    type = "A"
    ttl = "30"

    records = [aws_instance.java10x_sakila_yvelasquez_server_web_tf.public_ip]
}
