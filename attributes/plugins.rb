# List of base plugins to install. These plugins are absolute must inorder cookbook installation to proceed successfully. Override it at your own risk.
default['jenkins_config']['base_plugins'] = ['hipchat', 'mailer', 'saml', 'role-strategy', 'credentials', 'ssh-credentials']

# List of standard plugins to install. These plugins are required by LWRPS offered by jenkins_config/ jenkins cookbook. If you need additional plugins, include the folllowing along while overriding this attribute.
default['jenkins_config']['plugins'] = ['slack', 'multiple-scms', 'git', 'ssh-agent', 'credentials-binding']
