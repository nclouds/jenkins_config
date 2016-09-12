# Support whyrun
def whyrun_supported?
  true
end

action :install do
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Install #{@new_resource}") do
      install_plugin
    end
  end
end

action :uninstall do
  if @current_resource.exists
    converge_by("Delete #{@new_resource}") do
      uninstall_plugin
    end
  else
    Chef::Log.info "#{@current_resource} doesn't exist - can't delete."
  end
end

def load_current_resource
  @current_resource = Chef::Resource::JenkinsConfigPlugin.new(@new_resource.name)
  @current_resource.name(@new_resource.name)

  # Check for current resource
  @current_resource.exists = !plugin_installation_manifest(@new_resource.name).nil?
end

def get_transitive_dependencies(plugins_info, plugin_name)
  require 'set'
  set = Set.new
  queue = Queue.new

  queue << plugin_name
  until queue.empty?
    p = queue.pop
    next if set.include?(p)
    plugins_info['plugins'][p]['dependencies'].each do |dep|
      queue << dep['name']
    end
    set.add(p)
  end
  set.to_a
end

def get_dependencies(plugins_info, plugin_name)
  dependencies = []
  plugins_info['plugins'][plugin_name]['dependencies'].each do |d|
    dependencies << d['name']
  end
  dependencies
end

def install_plugin
  update_center_json = "#{Chef::Config[:file_cache_path]}/update_center_#{@current_resource.name}.json"

  remote_file update_center_json do
    source ::File.join(node['jenkins']['master']['mirror'], 'updates', 'update-center.json')
    action :nothing
  end.run_action(:create)

  extracted_json = ''

  # The downloaded file is composed of 3 lines. The first and the last line
  # are containing some javascript, the line in between contains the relevant
  # JSON data. That is the one that must be extracted.
  IO.readlines(update_center_json).map do |line|
    extracted_json = line unless line == 'updateCenter.post(' || line == ');'
  end

  plugins_info = JSON.parse(extracted_json)

  all_deps = get_transitive_dependencies(plugins_info, @new_resource.name)
  plugin_graph = {}
  all_deps.each do |d|
    plugin_graph[d] = get_dependencies(plugins_info, d)
  end
  ordered_plugin_list = plugin_graph.tsort
  ordered_plugin_list.each do |p|
    jenkins_plugin p do
      install_deps false
      action :install
    end
  end
end

def uninstall_plugin
  jenkins_plugin @new_resource.name do
    action :uninstall
  end
end

def plugins_directory
  ::File.join(node['jenkins']['master']['home'], 'plugins')
end

def plugin_installation_manifest(plugin_name)
  manifest = ::File.join(plugins_directory, plugin_name, 'META-INF', 'MANIFEST.MF')
  Chef::Log.debug "Load #{plugin_name} plugin information from #{manifest}"

  return nil unless ::File.exist?(manifest)

  plugin_manifest = {}

  ::File.open(manifest, 'r', encoding: 'utf-8') do |file|
    file.each_line do |line|
      next if line.strip.empty?

      #
      # Example Data:
      #   Plugin-Version: 1.4
      #
      config, value = line.split(/:\s/, 2)
      config = config.tr('-', '_').downcase
      value = value.strip if value # remove trailing \r\n

      plugin_manifest[config] = value
    end
  end

  plugin_manifest
end
