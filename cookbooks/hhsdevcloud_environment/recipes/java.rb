#
# Cookbook Name:: hhsdevcloud_environment
# Recipe:: java
#
# This wraps the supermarket's cookbook, applying the configuration needed
# in our environment.
#

# Install JIRA using the vendor's installer.
include_recipe 'java'


# There doesn't appear to be any way to setup LDAP auth here, so that will have
# to be handled in the GUI after install. Boo.

