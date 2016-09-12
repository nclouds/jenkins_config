if defined?(ChefSpec)
  ChefSpec.define_matcher :jenkins_config_job
  def create_jenkins_config_job(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(
      :jenkins_config_job,
      :create,
      resource_name)
  end

  def delete_jenkins_config_job(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(
      :jenkins_config_job,
      :delete,
      resource_name)
  end

  ChefSpec.define_matcher :jenkins_config_plugin
  def install_jenkins_config_plugin(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(
      :jenkins_config_plugin,
      :install,
      resource_name)
  end

  def uninstall_jenkins_config_plugin(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(
      :jenkins_config_plugin,
      :uninstall,
      resource_name)
  end

end
