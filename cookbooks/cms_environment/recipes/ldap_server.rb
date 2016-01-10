#
# Cookbook Name:: cms_environment
# Recipe:: ldap_server
#

Not much to do here; just wrap the supermarket recipe.
include_recipe 'openldap::server'
