# jenkins_config

Cookbook for Jenkins Configuration. This cookbook provides LWRPs to configure jenkins post installation. The installation can be done using jenkins cookbook

## Recipes

### default

This recipe includes all other recipes in the cookbook

### plugins

This recipe installs required and optional plugins that are required by jenkins_config_job LWRP

__Attributes__<BR/>
`node['jenkins_config']['base_plugins']` -> Base plugins that needs to be installed. Jenkins is restarted immediately, after every each plugin install. However, jenkins is not restarted when dependencies are installed.

`node['jenkins_config']['plugins']` -> Optional plugins that needs to be installed. Jenkins is restarted at the end of chef run.

## Resource/Provider

### jenkins_config_job

This resource manages Jenkins jobs, supporting the following actions:

```
:create, :delete, :disable, :enable
```

The resource is fully idempotent and convergent. It also supports why-run mode.

It uses jenkins_job LWRP part of jenkins cookbook to manage jobs. This LWRP assists in generating attributes from individual commands. This LWRP creates configurations that are dependent on the following plugins
* slack
* multiscm
* git
* credentials
* credentials-binding
* ssh-agent

Missing these plugins may case job creation to fail.

__Attributes__

* name -> Name of the job
* jobconfig_erb_params -> Global variables passed to the ERB which generates the job xml.
* builders -> Array of jsons representing each supported build steps.
* notifiers -> Array of jsons representing each supported notifiers.
* scms -> Array of SCM configurations. Uses multiscm plugin to configure SCM.
* job_parameters -> Array of parameters to the jenkins job
* auth_token -> If specified, enables remote trigger of jenkins job using the auth_token provided

Example job to execute a shell builder with support for slack notification
```ruby
jenkins_config_job 'bashdemo2' do
  action :create
  build_steps [
    {
      'builder' => 'shell',
      'command_erb' => 'bashdemo_sh1.erb'
    }
  ]
  notifiers [
    {
      'type' => 'slack',
      'notify_on' => ['success', 'failure'],
      'domain' => 'nclouds',
      'channel' => 'chat_testing1',
      'auth_token' => '<<your secret auth token>>'
    }
  ]
  params 'name' => 'Bob'
end
```

#### Job Configuration
This is an evolving LWRP. The following configurations are being supported. More options to be added later.

##### General configuration
__Parameters__<BR>
The attribute `job_parameters` can be used to pass the list of Job Parameters. The following types of parameters are supported
* boolean
* string

Example Usage :
```ruby
jenkins_config_job 'job1' do
  job_parameters [
    {
      'name' => 'branch_name',
      'type' => 'string',
      'default_value' => 'master'
    },
    {
      'name' => 'deploy',
      'type' => 'boolean'
    }
end
```

##### Source code management
___SCM Management___<BR>
The attribute `scms` can be used specify list of source repositories. git is the only supported type of scm.

Example Usage :
```ruby
jenkins_config_job 'job2' do
  scms [
    {
      'type' => 'git',
      'url' => 'git@bitbucket.org:nclouds/ken.git',
      'credentials_id' => 'XXX', # Credentials id in case of a private repository
      'branch' => '*/master'
      'checkout_folder' => '' # Local subfolder to checkout the project to incase of multiple SCMS.
    }
  ]
end
```
##### Build Triggers
__Remote Trigger__<BR>
The attribute `auth_token` can be used to enable remote builds. The auth_token can be be embedded in the URL for authentication. If left unspecified, remote build triggers will be disabled

Example Usage :
```ruby
jenkins_config_job 'job2' do
  auth_token '<<Your Secret>>'
end
```

##### Build Environment
__Credentials Binding__<BR>
The attribute `credentials_binding` can be used pass list of credentials that can be injected into the jenkins jobs. Currently the following types of credentials are supported
* text
* password

Example Usage:
```ruby
jenkins_config_job 'jobname' do
  credentials_binding [
    {
      'type' => 'text',
      'credentials_id' => '<<credentials_id>>', # The same id passed to jenkins_secret_text_credentials LWRP while creating the secret
      'variable_name' => 'VAULT_PASSWORD' # Env variable which will be used by the scripts to refer to the credential
    },
    {
      'type' => 'password',
      'credentials_id' => '<<credentials_id>>', # The samd id passed to jenkins_password_credentials LWRP while creating the secret
      'user_variable_name' => 'AWS_ACCESS_KEY', # Env variable name for referring the username from script
      'password_variable_name' => 'AWS_SECRET_KEY' # Env variable name for referring the password from script
    }
  ]
end
```
Note: credentials_id passed to type:text must always be of type secrettext credentials type. Matching with other type of credentials will cause unexpected results.

__SSH Agent__<BR>
The attribute `ssh_agent` can be used to configure ssh agent while running jenkins jobs.

Example Usage:
```ruby
jenkins_config_job 'jobname' do
  ssh_agent 'credential_ids' => [<<id1>>, <<id2>>] # The same id passed to jenkins_private_key_credentials LWRP while creating the secret.
end
```

##### Build Actions
The `build_steps` parameters can be used to pass a list of ordered build actions.

The following build actions are supported
* Shell script

__Shell Script__<BR>
The shell script can be created as an \*.erb file. The ERB will have access to `node` object and any other parameters that are passed via `jobconfig_erb_params`

Example Usage:
Template (templates/default/hello_world.sh.erb)
```ruby
whoami
printenv
echo "Hello <%=@jobconfig_erb_params['name']%>"
```

Parameter
```ruby
jenkins_config_job 'job2' do
  jobconfig_erb_params name: 'Bob'
  build_steps [
    {
      'builder' => 'shell',
      'command_erb' => 'hello_world.sh.erb'
    }
  ]
end
```

##### Post-Build Actions
The post build actions can be specified using `notifiers` parameter. The following post-build actions are supported.

__Slack Notifications__<BR>
The slack notifications that are supported slack plugin can be specified.

Example Usage :
```ruby
jenkins_config_job 'job1' do
  notifiers [
    {
      'type' => 'slack',
      'notify_on' => %w(start success failure aborted not_built unstable back_to_normal repeated_failure), # Exhaustive list of notification options. Pass in the relavant values for restricting notifications
      'domain' => node['nclouds_jenkins']['slack']['domain'],
      'channel' => node['nclouds_jenkins']['slack']['channel'],
      'auth_token' => node['nclouds_jenkins']['slack']['auth_token']
    }
  ]
```





### jenkins_config_plugin

This resource manages Jenkins jobs, supporting the following actions:

```
:install, :uninstall
```

The resource is fully idempotent and convergent. It also supports why-run mode.

It uses jenkins_lwrp LWRP part of jenkins cookbook to install plugins. This LWRP uses topological sorting of dependencies and installs the plugins in the proper order. This LWRP always installs the latest versions of the plugins to avoid dependency conflicts across multiple plugins

__Attributes__

* name -> Name of the plugin

```ruby
jenkins_config_plugin 'plugin1' do
  action :install
end
```
