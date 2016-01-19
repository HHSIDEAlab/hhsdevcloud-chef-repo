#
# Cookbook Name:: hhsdevcloud_environment
# Recipe:: jira
#
# This wraps the supermarket's cookbook, applying the configuration needed
# in our environment.
#

# Dependency: Java.
include_recipe 'hhsdevcloud_environment::java'

# Install JIRA using the vendor's installer.
include_recipe 'jira::installer'

# Create the JIRA DB.
if '127.0.0.1' != node['jira']['database']['host']
  include_recipe 'database::postgresql'
  postgresql_database node['jira']['database']['name'] do
    connection(
      :host     => node['jira']['database']['host'],
      :port     => node['jira']['database']['port'],
      :username => 'postgres',
      :password => node['postgresql']['password']['postgres']
    )
    encoding 'UTF8'
    action :create
  end

  # Create a user for the JIRA DB.
  postgresql_database_user node['jira']['database']['user'] do
    connection(
      :host     => node['jira']['database']['host'],
      :port     => node['jira']['database']['port'],
      :username => 'postgres',
      :password => node['postgresql']['password']['postgres']
    )
    password node['jira']['database']['password']
    database_name node['jira']['database']['name']
    action :create
  end
end

# There doesn't appear to be any way to setup LDAP auth here, so that will have
# to be handled in the GUI after install. Boo.

