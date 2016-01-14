name             'hhsdevcloud_environment'
version          '1.0.0'
license          'Apache v2'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))

# TODO See Berksfile.
#depends 'openldap', '~> 2.2.0'
depends 'openldap'
depends 'java', '~> 1.36.0'
depends 'jira', '~> 2.9.0'

