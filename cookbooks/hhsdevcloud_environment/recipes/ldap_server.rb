#
# Cookbook Name:: hhsdevcloud_environment
# Recipe:: ldap_server
#

# This recipe used to just use chef-cookbooks/openldap. However, that library
# is pretty badly broken. The biggest issue is that it doesn't support the
# `cn=config` dynamic config directory [1,2,3], which is very much "the future" 
# for OpenLDAP.
#
# Instead, we just install the required packages manually and push LDIFs to 
# configure things. Hokey, but works.
#
# [1] https://github.com/chef-cookbooks/openldap/issues/57
# [2] https://github.com/chef-cookbooks/openldap/pull/25
# [3] https://github.com/chef-cookbooks/openldap/pull/58

raise "Unsupported platform: #{node['platform']}" unless node['platform'] == 'ubuntu'

# We can still use the supermarket's client recipe.
include_recipe 'openldap::client'

# Install the server packages.
# References:
# * https://hub.docker.com/r/hlepesant/zacacia-openldap/~/dockerfile/
# * http://openstack.prov12n.com/quiet-or-unattended-installing-openldap-on-ubuntu-14-04/
bash 'preseed slapd' do
  code <<-EOH
    echo 'slapd slapd/domain string hhsdevcloud.us' |debconf-set-selections
    echo 'slapd shared/organization string HHS Dev Cloud' |debconf-set-selections
    echo 'slapd slapd/backend string HDB' |debconf-set-selections
    echo "slapd slapd/password1 password #{node['openldap']['rootpw']}" |debconf-set-selections
    echo "slapd slapd/password2 password #{node['openldap']['rootpw']}" |debconf-set-selections
    EOH
  # Only makes sense to run this before the package is installed. Applying this
  # afterwards would require a `dpkg-reconfigure` run.
  # FIXME seems to be broken: this resource never runs
  # not_if "dpkg -l slapd"
end
package ['slapd','db-util']


#
# Adjust the `cn=config` data.
#
# The current config can be queried by running:
# $ sudo ldapsearch -Y EXTERNAL -H ldapi:/// -b cn=config | less
#

ldif_dir = "#{node['openldap']['dir']}/ldif"
directory ldif_dir do
  owner 'root'
  group 'root'
  mode '0444'
end

# Note: leaving this here, even though no entries need to be applied right now,
# as Ubuntu's default config is quite solid.
config_ldifs = []
config_ldifs.each do |ldif|
  ldif_path = "#{ldif_dir}/#{ldif}"

  # Create the LDIF file to be applied, which will also be used as a marker to 
  # ensure it's only ever applied once.
  template ldif_path do
    source "#{ldif}.erb"
    mode '0444'
    owner 'root'
    group 'root'
    notifies :run, "execute[apply #{ldif}]", :immediately
  end

  # Apply the LDIF file.
  execute "apply #{ldif}" do
    command "sudo ldapmodify -Y EXTERNAL -H ldapi:/// -f #{ldif_path}"
    action :nothing
  end
end


#
# Adjust the `dc=hhsdevcloud,dc=us` data.
#
# The current directory can be queried by running:
# $ ldapsearch -x -D cn=admin,dc=hhsdevcloud,dc=us -w #{node['openldap']['rootpw']} -H ldapi:/// -b dc=hhsdevcloud,dc=us | less
#

dir_ldifs = ['directory.ldif','karl.ldif']
dir_ldifs.each do |ldif|
  ldif_path = "#{ldif_dir}/#{ldif}"

  # Create the LDIF file to be applied, which will also be used as a marker to 
  # ensure it's only ever applied once.
  template ldif_path do
    source "#{ldif}.erb"
    mode '0444'
    owner 'root'
    group 'root'
    notifies :run, "execute[apply #{ldif}]", :immediately
  end

  # Apply the LDIF file.
  execute "apply #{ldif}" do
    command "ldapmodify -x -D cn=admin,dc=hhsdevcloud,dc=us -w #{node['openldap']['rootpw']} -H ldapi:/// -f #{ldif_path}"
    action :nothing
  end
end

