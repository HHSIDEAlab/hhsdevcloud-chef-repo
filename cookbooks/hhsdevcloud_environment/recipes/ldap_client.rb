#
# Cookbook Name:: hhsdevcloud_environment
# Recipe:: ldap_client
#

# Note: we're applying the 'client' recipe, instead of the 'auth' recipe.
# For one: the 'auth' recipe doesn't work on RHEL with SSH (the PAM configs 
# aren't quite right). More to the point, though, we really only want to allow
# key-based SSH login anyway, and LDAP just make that more complicated.
# See the TODO recipe for how SSH keys are distributed.
include_recipe 'openldap::client'

