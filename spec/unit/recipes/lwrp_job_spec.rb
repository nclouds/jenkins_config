#
# Cookbook Name:: jenkins_config
# Spec:: job
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'sample::job' do
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
    ChefSpec::ServerRunner.new(file_cache_path: @file_cache_path, step_into: ['jenkins_config_job'], cookbook_path: %W(#{@cookbook_path}))
  end
  cached(:chef_run) do
    chef_runner.converge(described_recipe)
  end
  before :all do
    @file_cache_path = Dir.mktmpdir
    @cookbook_path = ::File.join(Dir.mktmpdir, 'cookbooks')
  end

  it 'creates bashdemo1 jenkins job' do
    expect(chef_run).to create_template("#{@file_cache_path}/job_bashdemo1.xml")
    expect(chef_run).to create_jenkins_config_job('bashdemo1')
    expect(chef_run).to create_jenkins_job('bashdemo1')
  end

  after :all do
    FileUtils.rm_rf(@file_cache_path)
    FileUtils.rm_rf(@cookbook_path)
  end
end
