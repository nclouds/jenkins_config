name 'jenkins_config'
maintainer 'Bob'
maintainer_email 'ananda.manoharan@nclouds.com'
license 'all_rights'
description 'Installs/Configures jenkins_config'
long_description 'Installs/Configures jenkins_config'
version '1.0.2'

depends 'jenkins', '~> 2.5.0'
depends 'java', '~> 1.39.0'


source_url 'https://github.com/nclouds/jenkins_config.git' if respond_to?(:source_url)
issues_url 'https://github.com/nclouds/jenkins_config/issues' if respond_to?(:issues_url)