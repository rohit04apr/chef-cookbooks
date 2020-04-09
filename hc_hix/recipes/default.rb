#
# Cookbook Name:: hc_hix
# Recipe:: default
#
# Copyright (C) 2015 company
#
# All rights reserved - Do Not Redistribute
#
#
#%w{jboss hcbuild fuse}.each do |u|
#user "#{u}" do
#    action :create
#end
Chef::Log.info 'hc_hix::default recipe started'

##Creating users
node['hc_hix']['users'].each do |user|
    user user do
        action :create
    end
end

#Create directories required for jboss user
node['hc_hix']['jboss_dirs'].each do |dir|
  directory dir do
    mode '2775'
    owner 'jboss'
    group 'jboss'
    action :create
    recursive true
  end
end

#Create directories required for hcbuild user
node['hc_hix']['hcbuild_dirs'].each do |dir|
  directory dir do
    mode '2775'
    owner 'hcbuild'
    group 'hcbuild'
    action :create
    recursive true
  end
end

#Add members to a group
group node['hc_hix']['group'] do
  action :modify
  members node['hc_hix']['users']
  append true
end
