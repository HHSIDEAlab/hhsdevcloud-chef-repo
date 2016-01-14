#
# Cookbook Name:: cms_environment
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

