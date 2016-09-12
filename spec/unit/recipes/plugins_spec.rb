#
# Cookbook Name:: nclouds_jenkins
# Spec:: base
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'jenkins_config::plugins' do
  let(:chef_runner) do
    ChefSpec::ServerRunner.new do |node, _runner|
      node.set['jenkins_config']['base_plugins'] = %w(bp1 bp2)
      node.set['jenkins_config']['plugins'] = %w(p1 p2)
    end
  end

  cached(:chef_run) do
    chef_runner.converge(described_recipe) do
      chef_runner.resource_collection.insert(Chef::Resource::Service.new('jenkins', chef_runner.run_context))
    end
  end

  it 'converges successfully' do
    expect { chef_run }.to_not raise_error
  end

  it 'base plugins to be installed' do
    expect(chef_run).to install_jenkins_config_plugin('bp1')
    resource = chef_run.jenkins_config_plugin('bp1')
    expect(resource).to notify('service[jenkins]').to(:restart).immediately
    expect(chef_run).to install_jenkins_config_plugin('bp2')
    resource = chef_run.jenkins_config_plugin('bp2')
    expect(resource).to notify('service[jenkins]').to(:restart).immediately
  end

  it 'addon plugins to be installed' do
    expect(chef_run).to install_jenkins_config_plugin('p1')
    resource = chef_run.jenkins_config_plugin('p1')
    expect(resource).to notify('service[jenkins]').to(:restart).delayed
    expect(chef_run).to install_jenkins_config_plugin('p2')
    resource = chef_run.jenkins_config_plugin('p2')
    expect(resource).to notify('service[jenkins]').to(:restart).delayed
  end
end
