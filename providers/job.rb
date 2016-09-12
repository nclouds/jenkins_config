# Support whyrun
def whyrun_supported?
  true
end

action :create do
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{@new_resource}") do
      create_job
    end
  end
end

action :delete do
  if @current_resource.exists
    converge_by("Delete #{@new_resource}") do
      delete_job
    end
  else
    Chef::Log.info "#{@current_resource} doesn't exist - can't delete."
  end
end

def load_current_resource
  @current_resource = Chef::Resource::JenkinsConfigJob.new(@new_resource.name)
  @current_resource.name(@new_resource.name)

  # Check for current resource
  @current_resource.exists = false
end

def create_job
  job_xml = "#{Chef::Config[:file_cache_path]}/job_#{@current_resource.name}.xml"
  template job_xml do
    source 'job.xml.erb'
    action :nothing
    cookbook 'jenkins_config'
    variables build_steps: new_resource.build_steps,
              jobconfig_erb_params: new_resource.jobconfig_erb_params,
              notifiers: new_resource.notifiers,
              scms: new_resource.scms,
              job_parameters: new_resource.job_parameters,
              auth_token: new_resource.auth_token,
              credentials_binding: new_resource.credentials_binding,
              ssh_agent: new_resource.ssh_agent
  end.run_action(:create)

  jenkins_job @new_resource.name do
    config job_xml
  end
end

def delete_role
  jenkins_job @new_resource.name do
    action :delete
  end
end
