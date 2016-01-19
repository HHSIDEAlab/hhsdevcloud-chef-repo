#
# Cookbook Name:: hhsdevcloud_environment
# Recipe:: provision
#
# This provisions the machines that will compose the HHS Dev Cloud environment.
# It uses chef-provisioner, which seems to be only lightly documented. By far 
# the best resource I have found for it is this sample:
# https://github.com/chef-cookbooks/chef-server-cluster
#

require 'chef/provisioning/aws_driver'
with_driver 'aws::us-east-1'
with_machine_options bootstrap_options: {
#    key_name: "cms-karl",
#    key_path: "/home/karl/workspaces/cms/aws-cms-karl.pem",
    security_group_ids: ['sg-5973d520', 'sg-5f7ed826']
}

# Store the connection info for 'postgres-dev-infra' in a hash.
postgres_dev_infra_connection_info = {
  :port     => 5432,
  :username => 'postgres',
  # TODO needs to be a secret
  :password => 'secretsecret'
}

# This will be the DB server used for all dev infrastructure, e.g. JIRA, Sonar, etc.
rds_postgres_dev_infra = aws_rds_instance 'postgres-dev-infra' do
  engine "postgres"
  db_instance_class "db.t2.micro"
  allocated_storage 10

  port postgres_dev_infra_connection_info[:port]
  publicly_accessible false
  multi_az false

  master_username postgres_dev_infra_connection_info[:username]
  master_user_password postgres_dev_infra_connection_info[:password]
end

# JIRA will run on its own box, since its install is a bit complex.
machine 'jira-srv' do
  machine_options bootstrap_options: {
    # JIRA System requirements:
    # https://confluence.atlassian.com/jira/jira-requirements-185729596.html#JIRARequirements-JIRAServerHardwareRecommendationforProduction
    # (2+ CPUs, 2GB+ RAM)
    instance_type: "t2.small",

    # Ubuntu 14.04
    image_id: "ami-d05e75b8",
    
    # The 'default' group, and then allow SSH.
    security_group_ids: ['sg-5973d520', 'sg-5f7ed826']
  }

  recipe 'hhsdevcloud_environment::default'
  recipe 'hhsdevcloud_environment::jira'

  attribute ['jira', 'database', 'host'], lazy { rds_postgres_dev_infra.aws_object.endpoint_address }
  attribute ['jira', 'database', 'name'], 'jiradb'
  attribute ['jira', 'database', 'user'], 'jira'
  # TODO store in a secret
  attribute ['jira', 'database', 'password'], 'secretsecret'
  attribute ['postgresql', 'password', 'postgres'], postgres_dev_infra_connection_info[:password]
end

