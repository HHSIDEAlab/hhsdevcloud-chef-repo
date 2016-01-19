#
# Cookbook Name:: hhsdevcloud_environment
# Recipe:: default
#

if node['platform_family'] == 'debian'
  # Ensure that `apt-get update` is run once per day.
  include_recipe 'apt::default'
end
