jenkins_config_job 'bashdemo1' do
  action :create
  job_parameters [
    {
      'name' => 'deploy_branch',
      'type' => 'string',
      'default_value' => 'master'
    },
    {
      'name' => 'Deploy_ehonda',
      'type' => 'boolean'
    }
  ]
  scms [
    {
      'type' => 'git',
      'url' => 'git@bitbucket.org:nclouds/ken.git'
    }
  ]
  build_steps [
    {
      'builder' => 'shell',
      'command_erb' => 'retrieve_ken_stack_hosts.erb'
    },
    {
      'builder' => 'shell',
      'command_erb' => 'deploy_ken_stack_hosts.erb'
    }
  ]
  notifiers [
    {
      'type' => 'slack',
      'notify_on' => %w(start success failure aborted not_built unstable back_to_normal repeated_failure),
      'domain' => 'nclouds',
      'channel' => 'chat_testing1',
      'auth_token' => 'xxx'
    }
  ]
end
