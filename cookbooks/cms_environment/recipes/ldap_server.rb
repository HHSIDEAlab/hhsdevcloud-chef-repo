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

#
# Import the schemas to be used.
#
schemas = ['cosine.ldif', 'nis.ldif', 'inetorgperson.ldif']
schemas.each do |schema|
  schema_path = "#{node['openldap']['dir']}/schema/#{schema}"

  # Create a marker file, to ensure it's only added once.
  file "#{schema_path}.added" do
    content ''
    mode '0444'
    owner 'root'
    group 'root'
    notifies :run, "execute[import_schema #{schema}]", :immediately
  end

  # Apply the LDIF file.
  execute "import_schema #{schema}" do
    command "ldapadd -Y EXTERNAL -H ldapi:/// -f #{schema_path}"
    action :nothing
  end
end


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

config_ldifs = ['config.ldif']
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
    command "ldapmodify -Y EXTERNAL -H ldapi:/// -f #{ldif_path}"
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

