#
# Cookbook Name:: hc_jasper
# Recipe:: wig_jasper
#
# Copyright (c) 2016 company, All Rights Reserved
#

#Get artifactory credentials from databag
artfct_user_details = data_bag_item('chef_credentials', 'artifactory')

#Download jasper setup from artifactory
remote_file "#{node['hc_jasper']['wig']['jasper_home']}/#{node['hc_jasper']['wig']['jasper_tar_name']}" do
  source "http://#{artfct_user_details['username']}:#{artfct_user_details['password']}@#{node['hc_jasper']['wig']['jasper_url']}"
  owner 'root'
  group 'root'
  mode '0755'
  action :create_if_missing
  notifies :run, "execute[extract jasper tar]", :immediately
end

execute 'extract jasper tar' do
  cwd node['hc_jasper']['wig']['jasper_home']
  user 'root'
  group 'root'
  command "tar xvf #{node['hc_jasper']['wig']['jasper_tar_name']} -C #{node['hc_jasper']['wig']['jasper_home']}"
  action :nothing
  not_if { ::File.exists?("#{node['hc_jasper']['wig']['jasper_setup']}") }
end

remote_file "#{node['hc_jasper']['wig']['jasper_home']}/#{node['hc_jasper']['wig']['jasper_license_tar']}" do
  source "http://#{artfct_user_details['username']}:#{artfct_user_details['password']}@#{node['hc_jasper']['wig']['license_url']}"
  owner 'root'
  group 'root'
  mode '0755'
  action :create_if_missing
  notifies :run, "execute[extract jasper license tar]", :immediately
end

execute 'extract jasper license tar' do
  cwd node['hc_jasper']['wig']['jasper_home']
  user 'root'
  group 'root'
  command "tar xvf #{node['hc_jasper']['wig']['jasper_license_tar']} -C #{node['hc_jasper']['wig']['jasper_home']}"
  action :nothing
  not_if { ::File.exists?("#{node['hc_jasper']['wig']['jasper_license']}") }
end

execute 'jasper_startup_comand' do
  cwd node['hc_jasper']['wig']['jasper_home']
  user 'root'
  group 'root'
  umask '002'
  command "./#{node['hc_jasper']['wig']['jasper_setup']} --mode unattended --prefix #{node['hc_jasper']['wig']['jasper_path']} --postgres_password password"
  action :run
end

execute 'jasper_permissions_change' do
  cwd node['hc_jasper']['wig']['jasper_path']
  command "chown -R #{node['hc_jasper']['wig']['user']}:#{node['hc_jasper']['wig']['group']} #{node['hc_jasper']['wig']['jasper_path']}"
  action :run
end

directory "node['hc_jasper']['wig']['jasper_package_path']" do
  owner 'hcbuild'
  group 'hcbuild'
  mode '0755'
  recursive true
  action :create
end


#Cleanup downloaded tar
Chef::Log.info "hc_jasper Cleaning up unwanted files......"
node['hc_jasper']['wig']['jasper_array'].each do |file|
  file "#{node['hc_jasper']['wig']['jasper_array']}/#{file}" do
    action :delete
    backup false
  end
end

template "#{node['hc_jasper']['wig']['jasper_path']}/js.spring.properties" do
  source 'product/wig/js.spring.properties.erb'
  mode '0644'
  owner node['hc_users']['users']
  group node['hc_users']['group']
  user_details = data_bag_item(node.chef_environment, "#{node['product']}_#{node['implementation']}" )
  variables(
    :username => user_details['jasper_username'],
    :password => user_details['jasper_password'],
  )
end

template "#{node['hc_jasper']['wig']['jasper_path']}/applicationContext-externalAuth-preAuth.xml" do
  source 'product/wig/applicationContext-externalAuth-preAuth.xml.erb'
  mode '0644'
  owner node['hc_users']['users']
  group node['hc_users']['group']
end

template "#{node['hc_jasper']['wig']['jasper_path']}/applicationContext-wig.xml" do
  source 'product/wig/applicationContext-wig.xml.erb'
  mode '0644'
  owner node['hc_users']['users']
  group node['hc_users']['group']
end

template "#{node['hc_jasper']['wig']['tomcat_server_xml_path']}/server.xml" do
  source 'product/wig/server.xml.erb'
  mode '0644'
  owner node['hc_users']['users']
  group node['hc_users']['group']
end

#Download jasper setup from artifactory
node['hc_jasper']['wig']['jasper_jars'].each do |jar|
remote_file "#{node['hc_jasper']['wig']['jar_path']}/#{jar}" do
  source "http://#{artfct_user_details['username']}:#{artfct_user_details['password']}@#{node['hc_jasper']['wig']['jar_url']}/#{jar}.tar.gz"
  owner 'root'
  group 'root'
  mode '0755'
  action :create_if_missing
  end
end

node['hc_jasper']['wig']['jasper_jars'].each do |jar|
  execute 'extract jasper jar' do
    cwd node['hc_jasper']['wig']['jar_path']
    user 'root'
    group 'root'
    command "tar xvf #{jar}.tar.gz -C #{node['hc_jasper']['wig']['jar_path']}"
  end
end

# update jasper service file.
  template "/etc/init.d/jasper" do
  source 'product/wig/jasper.erb'
  mode '0755'
  owner "root"
  group "root"
end

# Enable service on boot
service "jasper" do
  action [ :enable, :start ]
end

template "#{node['hc_jasper']['wig']['jasper_path']}/apache-tomcat/webapps/jasperserver-pro/WEB-INF/applicationContext-security-web.xml" do
  source 'product/wig/applicationContext-security-web.xml.erb'
  mode '0644'
  owner node['hc_users']['users']
  group node['hc_users']['group']
end

template "#{node['hc_jasper']['wig']['jasper_path']}/apache-tomcat/webapps/jasperserver-pro/scripts/client/jasper.js" do
  source 'product/wig/jasper.js'
  mode '0644'
  owner node['hc_users']['users']
  group node['hc_users']['group']
end

template "#{node['hc_jasper']['wig']['jasper_path']}/apache-tomcat/webapps/jasperserver-pro/WEB-INF/classes/esapi/security.properties" do
  source 'product/wig/security.properties.erb'
  mode '0644'
  owner node['hc_users']['users']
  group node['hc_users']['group']
end

template "#{node['hc_jasper']['wig']['jasper_path']}/apache-tomcat/webapps/jasperserver-pro/WEB-INF/jsp/templates/login.jsp" do
  source 'product/wig/login.jsp'
  mode '0644'
  owner node['hc_users']['users']
  group node['hc_users']['group']
end

execute 'configure jasper reports' do
  cwd node['hc_jasper']['wig']['jasper_path']
  user 'root'
  group 'root'
  command "./postgresql/bin/psql postgres -d jasperserver  -c \"update jicustomdatasourceproperty set value='<mongo-db-hostname>' where value='10.10.0.49'\""
end
 #Cleanup downloaded tar

Chef::Log.info "hc_jasper Cleaning up unwanted files......"
node['hc_jasper']['wig']['jasper_jars'].each do |tar|
  file "#{node['hc_jasper']['wig']['jar_path']}/#{tar}.tar.gz" do
    action :delete
    backup false
  end
end

