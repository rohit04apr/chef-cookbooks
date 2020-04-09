#
# Cookbook Name:: hc_sudo
# Recipe:: default
#
# Copyright (C) 2015 company
#
# All rights reserved - Do Not Redistribute
#
#
Chef::Log.info 'hc_sudo::default recipe execution started'

user node['jenkins']['user'] do
  action :create
end

directory "/home/#{node['jenkins']['user']}/.ssh" do
  owner node['jenkins']['user']
  group node['jenkins']['user']
  mode '0755'
  action :create
end

authorized_keys_file = "/home/#{node['jenkins']['user']}/.ssh/authorized_keys"

template authorized_keys_file do
  source "authorized_keys.erb"
  owner node['jenkins']['user']
  group node['jenkins']['user']
  mode "0600"
  variables :ssh_keys => node['jenkins']['keys']
end

sudo 'root' do
  user 'root'
  defaults ['!requiretty']
end

sudo 'jenkins_user' do
  user node['jenkins']['user']
  runas 'ALL'
  commands node['jenkins']['commands']
  nopasswd true
  defaults ['!requiretty']
end

Chef::Log.info 'hc_sudo::default recipe execution finished'
