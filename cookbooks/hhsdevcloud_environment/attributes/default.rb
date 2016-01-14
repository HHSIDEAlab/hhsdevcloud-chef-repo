#
# Cookbook Name:: hhsdevcloud_environment
# Attributes:: default
#


#
# ../recipes/ldap_server.rb
# 
# Parent cookbook defaults: 
# https://github.com/chef-cookbooks/openldap/blob/master/attributes/default.rb
#
default['openldap']['basedn'] = 'dc=hhsdevcloud,dc=us'
default['openldap']['server'] = 'ldap.hhsdevcloud.us'
default['openldap']['rootpw'] = 'hhs_secret'
default['openldap']['tls_enabled'] = false


#
# ../recipes/java.rb
# 
# Parent cookbook defaults: 
# https://github.com/agileorbit-cookbooks/java/blob/master/attributes/default.rb
#

# Install Oracle's JDK 8
default['java']['jdk_version'] = '8'
default['java']['install_flavor'] = 'oracle'
default['java']['accept_oracle_download_terms'] = true

# Install the JCE extensions for strong crypto
default['java']['oracle']['jce']['enabled'] = true

# Set the JDK to be the default on the path, and set the 'JAVA_HOME' env var.
default['java']['set_default'] = true
default['java']['set_etc_environment'] = true


#
# ../recipes/jira.rb
# 
# Parent cookbook defaults: 
# https://github.com/afklm/jira/blob/master/attributes/default.rb
#
default['jira']['version'] = '7.0.4'
default['jira']['autotune']['enabled'] = false
default['jira']['jvm']['maximum_memory']  = '2g'

