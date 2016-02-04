#
# Cookbook Name:: hhsdevcloud_chef_bootstrap
# Recipe:: default
#

require 'chef/provisioning/aws_driver'
with_driver 'aws::us-east-1'

# Create/reference the EC2 key pair to use for new instances.
aws_key_pair 'aws-hhsdevcloud' do
  # FIXME Can't get the paths to work correctly. Would like to store this in `~/.ssh`.
  #private_key_path File.expand_path('~/.ssh/aws-hhsdevcloud.pem')
  private_key_options({
    :format => :pem,
    :type => :rsa,
    :regenerate_if_different => true
  })
  allow_overwrite false
end

with_machine_options :bootstrap_options => {
    # FIXME these seem to be ignored unless copy-pasted into each machine
    :key_name => 'aws-hhsdevcloud',

    # FIXME these need to not be hardcoded; differs for each AWS account
    # The 'default' group, and then allow SSH.
    :security_group_ids => ['sg-5973d520', 'sg-5f7ed826']
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

machine 'chef-server' do
  machine_options bootstrap_options: {
    # Chef System requirements:
    # https://docs.chef.io/chef_system_requirements.html#chef-server-title-on-premises
    # (4+ CPUs, 4GB+ RAM, 10GB+ disk space)
    # This instance type has 2 vCPUs and 4GB RAM (we're cheating a bit on CPUs).
    instance_type: "t2.medium",

    # Ubuntu 14.04
    image_id: "ami-d05e75b8",

    key_name: 'aws-hhsdevcloud',

    # FIXME these need to not be hardcoded; differs for each AWS account
    # The 'default' group, and then allow SSH.
    security_group_ids: ['sg-5973d520', 'sg-5f7ed826']
  }

  # Installs the Chef backend.
  recipe 'chef-server'
  recipe 'chef-server::addons'
  attribute ['chef-server', 'addons'], ['manage']
  #attribute ['chef-server', 'api_fqdn'], 'https://chef.example.com/foo'

  # The lines to add to chef-server.rb.
  # FIXME The `postgresql['vip']` value is showing up empty. Why?
  attribute ['chef-server', 'configuration'], lazy {
    <<-EOS.gsub /^\s*/, ''
      postgresql['external'] = true
      postgresql['vip'] = #{rds_postgres_dev_infra.aws_object.endpoint_address}
      postgresql['port'] = #{postgres_dev_infra_connection_info[:port]}
      postgresql['db_superuser'] = #{postgres_dev_infra_connection_info[:username]}
      postgresql['db_superuser_password'] = #{postgres_dev_infra_connection_info[:password]}
    EOS
  }
end

