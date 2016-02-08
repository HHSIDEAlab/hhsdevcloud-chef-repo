/*
 * Defines all of the AWS resources that should be created/managed by 
 * Terraform.
 */

provider "aws" {
  region = "us-east-1"
  #shared_credentials_file = "~/.aws/credentials"
  #profile = "default"
}

/*
 * Security Groups
 */
resource "aws_security_group" "ssh-all" {
  name = "ssh-all"
  description = "Allow all inbound SSH traffic."

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

/*
 * RDS (PostgreSQL) Instances
 */
resource "aws_db_instance" "postgres-dev-infra" {
  identifier = "postgres-dev-infra"
  engine = "postgres"
  instance_class = "db.t2.medium"
  allocated_storage = 10

  username = "${var.postgres_master_creds.username}"
  password = "${var.postgres_master_creds.password}"

  publicly_accessible = false
  vpc_security_group_ids = [ "${var.security_group_default.id}" ]
}

/*
 * EC2 Instances/Servers
 */
resource "aws_instance" "chef-server" {
  tags {
    Name = "chef-server"
  }

  # Ubuntu 14.04
  ami = "ami-d05e75b8"

  # This instance type has 2 vCPUs and 4GB RAM (we're cheating a bit on CPUs).
  instance_type = "t2.medium"

  security_groups = [
    "${var.security_group_default.name}",
    "${aws_security_group.ssh-all.name}"
  ]
  key_name = "${var.key_name}"

  # Run these commands on the new system to install Chef Server on it.
  provisioner "remote-exec" {
    inline = [
      "wget --quiet --output-document=/tmp/chef-server-core_12.4.1-1_amd64.deb https://packagecloud.io/chef/stable/packages/ubuntu/trusty/chef-server-core_12.4.1-1_amd64.deb/download",
      "sudo dpkg -i /tmp/chef-server-core_12.4.1-1_amd64.deb",
      "echo \"postgresql['external'] = true\" | sudo tee --append /etc/opscode/chef-server.rb",
      "echo \"postgresql['vip'] = '${aws_db_instance.postgres-dev-infra.address}'\" | sudo tee --append /etc/opscode/chef-server.rb",
      "echo \"postgresql['port'] = ${aws_db_instance.postgres-dev-infra.port}\" | sudo tee --append /etc/opscode/chef-server.rb",
      "echo \"postgresql['db_superuser'] = '${aws_db_instance.postgres-dev-infra.username}'\" | sudo tee --append /etc/opscode/chef-server.rb",
      "echo \"postgresql['db_superuser_password'] = '${var.postgres_master_creds.password}'\" | sudo tee --append /etc/opscode/chef-server.rb",
      "sudo chef-server-ctl reconfigure",
      "sudo chef-server-ctl user-create chefadmin Chef Admin chefadmin@hhsdevcloud.us '${var.chefadmin_password}' --filename /tmp/chefadmin.pem",
      "sudo chef-server-ctl org-create hhsdevcloud 'HHS Dev Cloud' --association_user chefadmin --filename /tmp/hhsdevcloud-validator.pem"
    ]

    connection {
      user = "ubuntu"
    }
  }

  # Copy the Chef server certs to the local machine running Terraform.
  provisioner "local-exec" {
command = <<EOS
scp -o 'StrictHostKeyChecking no' ubuntu@${aws_instance.chef-server.public_ip}:/tmp/chefadmin.pem ./chefadmin.pem
scp -o 'StrictHostKeyChecking no' ubuntu@${aws_instance.chef-server.public_ip}:/tmp/hhsdevcloud-validator.pem ./hhsdevcloud-validator.pem
EOS
  }
}

