actions :install, :uninstall
default_action :install

attribute :name, name_attribute: true, kind_of: String, required: true

attr_accessor :exists
