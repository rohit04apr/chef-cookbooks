#
# Cookbook Name:: hc_jasper
# Recipe:: hix_jasper
#
# Copyright (c) 2016 company, All Rights Reserved
#

 #Get artifactory credentials from databag
artfct_user_details = data_bag_item('chef_credentials', 'artifactory')


#Create direcotry

directory "#{node['hc_jasper']['hix']['jasper_temp_dir']}" do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
  not_if { ::File.exists?("#{node['hc_jasper']['hix']['jasper_temp_dir']}") }

end

#Download jasper setup from artifactory

remote_file "#{node['hc_jasper']['hix']['jasper_temp_dir']}/#{node['hc_jasper']['hix']['jasper_tar_name']}" do
    source "http://#{artfct_user_details['username']}:#{artfct_user_details['password']}@#{node['hc_jasper']['hix']['jasper_url']}"
    owner 'root'
    group 'root'
    mode '0755'
    action :create_if_missing
    not_if { ::File.exists?("#{node['hc_jasper']['hix']['jasper_path']}/licenses") }
    notifies :run, "execute[extract jasper tar]", :immediately
end

execute 'extract jasper tar' do
    cwd node['hc_jasper']['hix']['jasper_temp_dir']
    user 'root'
    group 'root'
    command "tar xvf #{node['hc_jasper']['hix']['jasper_tar_name']} -C #{node['hc_jasper']['hix']['jasper_temp_dir']}"
    action :nothing
    not_if { ::File.exists?("#{node['hc_jasper']['hix']['jasper_path']}/licenses") }
end

remote_file "#{node['hc_jasper']['hix']['jasper_temp_dir']}/#{node['hc_jasper']['hix']['jasper_license_tar']}" do
    source "http://#{artfct_user_details['username']}:#{artfct_user_details['password']}@#{node['hc_jasper']['hix']['license_url']}"
    owner 'root'
    group 'root'
    mode '0755'
    action :create_if_missing
    not_if { ::File.exists?("#{node['hc_jasper']['hix']['jasper_path']}/licenses") }
    notifies :run, "execute[extract jasper license tar]", :immediately
end

execute 'extract jasper license tar' do
    cwd node['hc_jasper']['hix']['jasper_temp_dir']
    user 'root'
    group 'root'
    command "tar xvf #{node['hc_jasper']['hix']['jasper_license_tar']} -C #{node['hc_jasper']['hix']['jasper_temp_dir']}"
    action :nothing
    not_if { ::File.exists?("#{node['hc_jasper']['hix']['jasper_path']}/licenses") }
end

execute 'jasper_startup_comand' do
    cwd node['hc_jasper']['hix']['jasper_temp_dir']
    user 'root'
    group 'root'
    retries 1
    retry_delay 10
    command "./#{node['hc_jasper']['hix']['jasper_setup']} --mode unattended --prefix #{node['hc_jasper']['hix']['jasper_path']} --postgres_password password"
    action :run
    not_if { ::File.exists?("#{node['hc_jasper']['hix']['jasper_path']}/licenses") }
end

#execute 'jasper_permissions_change' do
  execute 'change permission' do 
    cwd node['hc_jasper']['hix']['jasper_home']
    command "chown -R #{node['hc_jasper']['hix']['user']}:#{node['hc_jasper']['hix']['group']} #{node['hc_jasper']['hix']['jasper_path']}"
    action :run
end

# update jasper ctlscript service file.
 template "#{node['hc_jasper']['hix']['jasper_path']}/ctlscript.sh" do
    source 'product/hix/ctlscript.sh.erb'
    mode '0755'
    owner "jasper"
    group "jasper"
end


directory "#{node['hc_jasper']['hix']['jasper_package_path']}" do
   owner 'hcbuild'
   group 'hcbuild'
   mode '0755'
   recursive true
   action :create
end


 #Cleanup downloaded tar

Chef::Log.info "hc_jasper Cleaning up unwanted files......"

directory "#{node['hc_jasper']['hix']['jasper_temp_dir']}" do
  recursive true
  action :delete
end                     


# update jasper service file.
  template "/etc/init.d/jasper" do
  source 'product/hix/jasper.erb'
  mode '0755'
  owner "root"
  group "root"
end

# Enable service on boot
  service "jasper" do
  action [ :enable, :start ]
end


