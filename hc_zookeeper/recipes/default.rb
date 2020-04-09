# Cookbook Name:: hc_zookeeper
# Recipe:: default
#
# Copyright (c) 2016 company, All Rights Reserved.
#Get artifactory credentials from databag

log "hc_zookeeper::default:: Recipe execution started"
nodes = search(:node, "role:#{node['product']}* AND chef_environment:#{node.chef_environment}")
log "hc_zookeeper::default:: Total number of shared nodes in #{node.chef_environment} env :: #{nodes.length} only..."
node_hash = {}
len = nodes.length
nodes.each do |node| 
  fqdn = node['set_fqdn']
  id = fqdn.match(/(\d+)/)
  Chef::Log.info("hc_zookeeper::default:: fqdn is #{fqdn} and id is #{id}")
  node_hash[id] = node['set_fqdn']
end
node_hash.each do |k,v|
  Chef::Log.info("hc_zookeeper::default:: key is #{k} and server name is #{v}")
end
artfct_user_details = data_bag_item('chef_credentials','artifactory')
node['hc_zookeeper']['dirs'].each do |dir|
  directory dir do
    mode '0755'
    action :create
    owner node['hc_zookeeper']['user']
    group node['hc_zookeeper']['group']
  end
end

#Download tar package from artifactory
remote_file "download_install_file" do
  source "http://#{artfct_user_details['username']}:#{artfct_user_details['password']}@#{node['hc_zookeeper']['package']['url']}"
  mode '0755'
  path "#{node['hc_zookeeper']['install']['tmp']}/#{node['hc_zookeeper']['package']['name']}"
  action :create
end

execute 'extract_zookeeper_tar' do
  cwd node['hc_zookeeper']['install']['tmp']
  command "tar -xzf #{node['hc_zookeeper']['package']['name']} -C #{node['hc_zookeeper']['install_path']}"
  #action :nothing
  notifies :run, "execute[chown_zkp]", :immediately
end

execute 'chown_zkp' do
  command  "chown -R #{node['hc_zookeeper']['user']}:#{node['hc_zookeeper']['group']} #{node['hc_zookeeper']['install_path']}/zookeeper-#{node['hc_zookeeper']['version']}"
  action :nothing
end

link "#{node['hc_zookeeper']['install_path']}/zookeeper" do
  to "#{node['hc_zookeeper']['install_path']}/zookeeper-#{node['hc_zookeeper']['version']}"
end

template "#{node['hc_zookeeper']['install_path']}/zookeeper-#{node['hc_zookeeper']['version']}/conf/zoo.cfg" do
  source 'zoo.cfg.erb'
  variables :nodes => node_hash
  #action :nothing
end

template "#{node[:hc_zookeeper][:config][:dataDir]}/myid" do
  source 'myid.erb'
  fqdn = node['set_fqdn']
  id = fqdn.match(/(\d+)/)
  variables(
    :id => id
    )
end

template '/etc/default/zookeeper' do
  source 'environment-defaults.erb'
  owner node[:hc_zookeeper][:user]
  group node[:hc_zookeeper][:user]
  action :create
  mode '0644'
  notifies :restart, 'service[zookeeper]', :delayed
end

template '/etc/init.d/zookeeper' do
  source 'zookeeper.erb'
  owner 'root'
  group 'root'
  action :create
  mode '0755'
  notifies :restart, 'service[zookeeper]', :delayed
end

template "#{node['hc_zookeeper']['install_path']}/zookeeper-#{node['hc_zookeeper']['version']}/conf/log4j.properties" do
  source 'log4j.properties.erb'
  owner 'zookeeper'
  group 'zookeeper'
  action :create
  mode '0755'
  notifies :restart, 'service[zookeeper]', :delayed
end

service 'zookeeper' do
  supports status: true, restart: true, reload: true
  action :enable
end

cron 'zookeeper' do
  hour '0'
  minute '0'
  user 'zookeeper'
  command "#{node['hc_zookeeper']['install_path']}/zookeeper-#{node['hc_zookeeper']['version']}/bin/zkCleanup.sh -n 3"
  action :create
end
log "hc_zookeeper::default:: Recipe execution finished"