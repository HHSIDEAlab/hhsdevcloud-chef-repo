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


# There doesn't appear to be any way to setup LDAP auth here, so that will have
# to be handled in the GUI after install. Boo.

