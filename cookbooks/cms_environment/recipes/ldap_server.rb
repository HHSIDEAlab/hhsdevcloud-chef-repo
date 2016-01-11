#
# Cookbook Name:: cms_environment
# Recipe:: ldap_server
#

# Apply the fix in https://github.com/chef-cookbooks/openldap/pull/55, which 
# isn't in the latest 2.2.0 release.
if node['platform_family'] == 'rhel'
  node.default['openldap']['packages']['bdb'] = 'libdb-utils'
end

# Aside from that, just apply the supermarket recipe.
include_recipe 'openldap::server'
