#
# Cookbook Name:: jenkins_config
# Spec:: job
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'sample::plugin' do
  let(:chef_runner) do
    opts = RSpec.configuration.berkshelf_options
    raise InvalidBerkshelfOptions(value: opts.inspect) unless opts.is_a?(Hash)
    berksfile = ::Berkshelf::Berksfile.from_file('spec/sample/Berksfile', opts)

    ::Berkshelf.ui.mute do
      if ::Berkshelf::Berksfile.method_defined?(:vendor)
        # Berkshelf 3.0 requires the directory to not exist
        FileUtils.rm_rf(@cookbook_path)
        berksfile.vendor(@cookbook_path)
      else
        berksfile.install(path: @cookbook_path)
      end
    end
    ChefSpec::ServerRunner.new(file_cache_path: @file_cache_path, step_into: ['jenkins_config_plugin'], cookbook_path: %W(#{@cookbook_path}))
  end
  cached(:chef_run) do
    chef_runner.converge(described_recipe) do
      chef_runner.resource_collection.insert(Chef::Resource::Service.new('jenkins', chef_runner.run_context))
    end
  end
  before :all do
    @file_cache_path = Dir.mktmpdir
    @cookbook_path = ::File.join(Dir.mktmpdir, 'cookbooks')
    update_center_json_content = <<-EOS
updateCenter.post(
{"plugins":{"plugin1":{"dependencies":[{"name":"plugin2"}]},"plugin2":{"dependencies":[{"name":"plugin3"}]},"plugin3":{"dependencies":[]}}}
);
EOS
    File.open(File.join(@file_cache_path, 'update_center_plugin1.json'), 'w') { |file| file.write(update_center_json_content.strip) }
  end

  it 'creates update center json' do
    expect(chef_run).to create_remote_file(File.join(@file_cache_path, 'update_center_plugin1.json'))
  end

  it 'Installs all dependencies' do
    expect(chef_run).to install_jenkins_plugin('plugin1')
    expect(chef_run).to install_jenkins_plugin('plugin2')
    expect(chef_run).to install_jenkins_plugin('plugin3')
  end

  it 'Calls jenkins_config_plugin[plugin1]' do
    expect(chef_run).to install_jenkins_config_plugin('plugin1')
  end

  after :all do
    FileUtils.rm_rf(@file_cache_path)
    FileUtils.rm_rf(@cookbook_path)
  end
end
