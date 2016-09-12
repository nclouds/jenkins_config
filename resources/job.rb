actions :create, :delete
default_action :create

attribute :name, name_attribute: true, kind_of: String, required: true
attribute :job_parameters, default: []
attribute :auth_token, default: nil
attribute :credentials_binding, default: []
attribute :ssh_agent, default: {}
attribute :scms, default: []
attribute :build_steps, default: []
attribute :notifiers, default: []
attribute :jobconfig_erb_params, default: {}

attr_accessor :exists
