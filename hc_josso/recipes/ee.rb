#
# Cookbook Name:: hc_josso
# Recipe:: ee
#
# Copyright (c) 2016 company, All Rights Reserved.
begin

Chef::Log.info 'hc_josso::ee recipe execution started'
#create directories
node['hc_josso']['ee']['dirs'].each do |dir|
  directory "#{dir}" do
    owner 'idm'
    group 'idm'
    mode '2775'
    recursive true
    action :create
  end
end


#Get artifactory credentials from databag
artfct_user_details = data_bag_item('chef_credentials', node['chef_credentials']['artifactory'])

#Download ee jar from artifactory
remote_file "#{node['hc_josso']['ee']['josso_ee_path']}/#{node['hc_josso']['ee']['jar_name']}" do
  source "http://#{artfct_user_details['username']}:#{artfct_user_details['password']}@#{node['hc_josso']['ee']['url']}"
  owner 'idm'
  group 'idm'
  mode '0755'
  action :create_if_missing
  notifies :run, "execute[extract josso-ee tar]", :immediately
end

execute 'extract josso-ee tar' do
  cwd node['hc_josso']['ee']['josso_ee_path']
  user 'idm'
  group 'idm'
  command "tar xzvf #{node['hc_josso']['ee']['jar_name']} -C #{node['hc_josso']['ee']['josso_ee_path']}"
  action :nothing
  not_if { ::File.exists?("#{node['hc_josso']['ee']['jar_name']}") }
end

#download josso_license file
remote_file "#{node['hc_josso']['josso_envsetup']['dest_copy_path']}/atricore.lic" do
  source "http://#{artfct_user_details['username']}:#{artfct_user_details['password']}@#{node['hc_josso']['josso_envsetup']['license_download_path']}"
  owner 'idm'
  group 'idm'
  mode '0755'
  action :create
  end


template "#{node['hc_josso']['ee']['josso_ee_path']}/install" do
  source 'ee.install.erb'
  mode '0755'
  owner 'idm'
  group 'idm'
end

template "/etc/init.d/josso-ee" do
  source 'ee.service.erb'
  mode '0755'
  owner 'idm'
  group 'idm'
end

link '/etc/init.d/josso' do
  to '/etc/init.d/josso-ee'
end

#start the josso_ee

execute 'josso_startup_comand' do
  cwd node['hc_josso']['josso_envsetup']['dest_copy_path']
  user 'idm'
  group 'idm'
  umask '002'
  command "java -jar #{node['hc_josso']['ee']['jar_name']} install"
  action :run
end

template "#{node['hc_josso']['ee']['josso_ee_path']}/bin/atricore" do
  mode '0755'
  owner 'idm'
  group 'idm'
end

directory "#{node['hc_josso']['ee']['josso_ee_path']}/data/temp" do
  owner 'idm'
  group 'idm'
  mode '0755'
  recursive true
  action :create
end
#download josso_license file
remote_file "#{node['hc_josso']['josso_envsetup']['dest_copy_path']}/etc/atricore.lic" do
  source "http://#{artfct_user_details['username']}:#{artfct_user_details['password']}@#{node['hc_josso']['josso_envsetup']['license_download_path']}"
  owner 'idm'
  group 'idm'
  mode '0755'
  action :create
end


#change permission of josso setup
execute 'josso_permissions_change' do
  cwd node['hc_josso']['ee']['josso_ee_path']
  command "chmod -R 775 *"
  action :run
end


#josso_sleep

ruby_block "going into sleep mode for 10 seconds" do
block do
  sleep(20)
end
end

service 'josso-ee' do
action [:enable, :start]
end

ensure
#Cleanup downloaded tar
Chef::Log.info "hc_josso::ee Cleaning up unwanted files......"
node['hc_josso']['ee']['clean_files'].each do |file|
  file "#{node['hc_josso']['ee']['josso_ee_path']}/#{file}" do
    action :delete
    backup false
  end
end
end
Chef::Log.info 'hc_josso::ee recipe execution finished'
