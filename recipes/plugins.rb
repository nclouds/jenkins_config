node['jenkins_config']['base_plugins'].each do |name|
  jenkins_config_plugin name do
    notifies :restart, 'service[jenkins]', :immediately
  end
end

node['jenkins_config']['plugins'].each do |name|
  jenkins_config_plugin name do
    notifies :restart, 'service[jenkins]', :delayed
  end
end
