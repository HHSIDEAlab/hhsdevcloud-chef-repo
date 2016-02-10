/*
 * Defines all of the AWS resources that should be created/managed by 
 * Terraform. These are the application development resources for the HHS Dev 
 * Cloud.
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
resource "aws_db_instance" "postgres-dev" {
  identifier = "postgres-dev"
  engine = "postgres"
  instance_class = "db.t2.medium"
  allocated_storage = 10

  username = "${var.postgres_master_creds.username}"
  password = "${var.postgres_master_creds.password}"

  publicly_accessible = false
  vpc_security_group_ids = [ "${var.security_group_default.id}" ]
}

/*
 * EC2 Instance: Chef Server
 */
resource "aws_instance" "chef" {
  tags {
    Name = "chef"
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
      "echo \"postgresql['vip'] = '${aws_db_instance.postgres-dev.address}'\" | sudo tee --append /etc/opscode/chef-server.rb",
      "echo \"postgresql['port'] = ${aws_db_instance.postgres-dev.port}\" | sudo tee --append /etc/opscode/chef-server.rb",
      "echo \"postgresql['db_superuser'] = '${aws_db_instance.postgres-dev.username}'\" | sudo tee --append /etc/opscode/chef-server.rb",
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
scp -o 'StrictHostKeyChecking no' ubuntu@${aws_instance.chef.public_ip}:/tmp/chefadmin.pem ./chefadmin.pem
scp -o 'StrictHostKeyChecking no' ubuntu@${aws_instance.chef.public_ip}:/tmp/hhsdevcloud-validator.pem ./hhsdevcloud-validator.pem
EOS
  }
}

/*
 * EC2 Instance: LDAP Server
 */
resource "aws_instance" "ldap" {
  tags {
    Name = "ldap"
  }

  # Ubuntu 14.04
  ami = "ami-d05e75b8"

  # This instance type has 1 vCPU and 1GB RAM.
  instance_type = "t2.micro"

  security_groups = [
    "${var.security_group_default.name}",
    "${aws_security_group.ssh-all.name}"
  ]
  key_name = "${var.key_name}"

  provisioner "chef" {
    environment = "_default"
    run_list = [  ]
    node_name = "ldap"
    server_url = "https://${aws_instance.chef.private_dns}/organizations/hhsdevcloud"
    ssl_verify_mode = ":verify_none"
    validation_client_name = "hhsdevcloud-validator"
    validation_key = "${file("./hhsdevcloud-validator.pem")}"
    version = "12.4.1"

    connection {
      user = "ubuntu"
    }
  }
}

/*
 * EC2 Instance: JIRA Server
 */
resource "aws_instance" "jira" {
  tags {
    Name = "jira"
  }

  # Ubuntu 14.04
  ami = "ami-d05e75b8"

  # JIRA Recommended System Requirements (<= 5000 issues): 2+ vCPUs, 2+GB RAM, 10GB-50GB disk
  # Reference: https://confluence.atlassian.com/jira/jira-requirements-185729596.html#JIRARequirements-JIRAServerHardwareRecommendationforProduction
  # This instance type has 1 vCPUs and 1GB RAM (we're cheating on the recommendations)
  instance_type = "t2.micro"

  security_groups = [
    "${var.security_group_default.name}",
    "${aws_security_group.ssh-all.name}"
  ]
  key_name = "${var.key_name}"

  provisioner "chef" {
    environment = "_default"
    run_list = [  ]
    node_name = "jira"
    server_url = "https://${aws_instance.chef.private_dns}/organizations/hhsdevcloud"
    ssl_verify_mode = ":verify_none"
    validation_client_name = "hhsdevcloud-validator"
    validation_key = "${file("./hhsdevcloud-validator.pem")}"
    version = "12.4.1"

    connection {
      user = "ubuntu"
    }
  }
}

/*
 * EC2 Instance: Build Server (Jenkins+Sonar+Nexus)
 */
resource "aws_instance" "builds" {
  tags {
    Name = "builds"
  }

  # Ubuntu 14.04
  ami = "ami-d05e75b8"

  # This instance type has 2 vCPUs and 4GB RAM
  instance_type = "t2.medium"

  security_groups = [
    "${var.security_group_default.name}",
    "${aws_security_group.ssh-all.name}"
  ]
  key_name = "${var.key_name}"

  provisioner "chef" {
    environment = "_default"
    run_list = [  ]
    node_name = "builds"
    server_url = "https://${aws_instance.chef.private_dns}/organizations/hhsdevcloud"
    ssl_verify_mode = ":verify_none"
    validation_client_name = "hhsdevcloud-validator"
    validation_key = "${file("./hhsdevcloud-validator.pem")}"
    version = "12.4.1"

    connection {
      user = "ubuntu"
    }
  }
}

