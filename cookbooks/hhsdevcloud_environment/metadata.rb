name             'hhsdevcloud_environment'
version          '1.0.0'
license          'Apache v2'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))

# TODO See Berksfile.
#depends 'openldap', '~> 2.2.0'
depends 'openldap'
depends 'java', '~> 1.36.0'
depends 'jira', '~> 2.9.0'

recipe 'hhsdevcloud', 'TODO'
recipe 'hhsdevcloud::java', 'Installs an Oracle JDK/JRE and adds it to the system path.'
recipe 'hhsdevcloud::ldap_server', 'Sets up an OpenLDAP server, serving the dc=hhsdevcloud,dc=us directory.'
recipe 'hhsdevcloud::ldap_client', 'Configures the OpenLDAP client tools, for queries against the dc=hhsdevcloud,dc=us directory.'
recipe 'hhsdevcloud::jira', 'Sets up a JIRA server.'

