#
# Cookbook Name:: hc_tomcat
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
#

Chef::Log.info 'hc_tomcat::default recipe execution started'
# Grab and unpack tomcat package
artfct_user_details = data_bag_item('chef_credentials', node['chef_credentials']['artifactory'])


# SmartOS doesn't support multiple instances
template "#{node['hc_tomcat']['tomcat_home']}/bin/setenv.sh" do
  source 'product/phix/cp/kmssetenv.sh.erb'
  mode '0644'
  owner node['hc_tomcat']['user']
  group node['hc_tomcat']['group']
end

template "#{node['hc_tomcat']['tomcat_home']}/conf/Catalina/localhost/company-ds-tomcat.xml" do
  source 'product/phix/cp/kmscompany-ds-tomcat.xml.erb'
  mode '0644'
  owner node['hc_tomcat']['user']
  group node['hc_tomcat']['group']
end

remote_file "#{node['hc_tomcat']['tomcat_home']}/lib/company-datasourcefactory-1.0-SNAPSHOT.jar" do
  source "http://#{artfct_user_details['username']}:#{artfct_user_details['password']}@artifactory.demo.company.com/artifactory/chef-repo/kms/company-datasourcefactory-1.0-SNAPSHOT.jar"
  owner 'tomcat'
  group 'tomcat'
  mode '0755'
end

remote_file "#{node['hc_tomcat']['tomcat_home']}/lib/company-kms-provider-1.0-SNAPSHOT.jar" do
  source "http://#{artfct_user_details['username']}:#{artfct_user_details['password']}@artifactory.demo.company.com/artifactory/chef-repo/kms/company-kms-provider-1.0-SNAPSHOT.jar"
  owner 'tomcat'
  group 'tomcat'
  mode '0755'
end

service "tomcat" do
  action :restart
end

Chef::Log.info 'hc_tomcat::default recipe execution finished'

