variable "aws_profile" {}

provider "aws" {
  profile = "${var.aws_profile}"
  region = "us-east-1"
}

resource "aws_vpc" "challenge_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
}

# Creates a Subnet that should hopefully not conflict with anything.
resource "aws_subnet" "challenge_subnet" {
  vpc_id = "${aws_vpc.challenge_vpc.id}"
  cidr_block = "10.0.200.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id = "${aws_vpc.challenge_vpc.id}"

	ingress {
			from_port   = 0
			to_port     = 65535
			protocol    = "tcp"
			cidr_blocks = ["0.0.0.0/0"]
		}

	egress {
			from_port   = 0
			to_port     = 0
      protocol    = "-1"
			cidr_blocks = ["0.0.0.0/0"]
		}

}

resource "aws_network_interface" "network_interface" {
  subnet_id = "${aws_subnet.challenge_subnet.id}"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.challenge_vpc.id}"
}

resource "aws_route_table" "r" {
  vpc_id = "${aws_vpc.challenge_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_internet_gateway.gw.id}"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = "${aws_subnet.challenge_subnet.id}"
  route_table_id = "${aws_route_table.r.id}"
}

resource "aws_eip" "challenge_eip" {
  vpc = true
  instance = "${aws_instance.docker.id}"
}

# Probably would do this in a more secure fashion than this (This was generated specifically for this)
# Specifically not having the private key live with the repo
resource "aws_key_pair" "deployer" {
  key_name = "challenge-deployer"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDSCbHYt24tZ8SIT4ZcfXWI0Fvdv69dVNLlvOJb9jOk9SOpwda3KI7Kuqq/2u7FAGR3CjFK83qkT98nTQCsYhUp3wf3rUjoq8vnxrpgYULoXg60QzubXijzxUNkzRp53evk57Jfpvp0BU8tQUwjN+LIWP7tm4AR1HDgEaWa6pKDli9LpM5BGY6fCXQftLkSKpzulwJCc28gaLljoZjFGGlOHolcfom7TjqjqaS0T1TvyTi9gTZw7Qwf+96jZZlV80kGrTjRLXJb20edhLBlzXGupMbTjq7BLuuixHNu3BETffteDcSHdVGw3l00BZuU5G6m+9Yqyp+3OYXR0WcefnLZ knehring@gmail.com"
}

resource "aws_instance" "docker" {
  ami = "ami-0b542c1d"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.challenge_subnet.id}"
  key_name = "challenge-deployer"
	vpc_security_group_ids = ["${aws_security_group.allow_all.id}"]

  provisioner "remote-exec" {
    inline = [ 
      "mkdir /tmp/challenge"
    ]

    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = "${file("./challenge.pem")}"
    }
  }

  provisioner "file" {
    source = "."
    destination = "/tmp/challenge/"

    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = "${file("./challenge.pem")}"
    }
  }

  provisioner "remote-exec" {
    inline = [ 
      "chmod +x /tmp/challenge/install-docker.sh",
      "sh /tmp/challenge/install-docker.sh",
      "chmod +x /tmp/challenge/start.sh",
      "cd /tmp/challenge",
      "sh /tmp/challenge/start.sh"
    ]

    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = "${file("./challenge.pem")}"
    }
  }
}

output "enter_me" {
  value = "${aws_instance.docker.public_ip}"
}
