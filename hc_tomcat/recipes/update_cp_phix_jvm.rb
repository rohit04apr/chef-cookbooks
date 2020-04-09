#
# Cookbook Name:: hc_tomcat
# Recipe:: update_cp_phix_jvm
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
#

service node['hc_tomcat']['base_instance'] do
  action :stop
end

ruby_block 'going into sleep mode for 10 seconds' do 
  block do
    sleep(10)
  end
end

template "#{node['hc_tomcat']['tomcat_home']}/bin/setenv.sh" do
  source 'product/phix/cp/cp_phix_uat_setenv.sh.erb'
  mode '0644'
  owner node['hc_tomcat']['user']
  group node['hc_tomcat']['group']
  notifies :start, "service[#{node['hc_tomcat']['base_instance']}]", :immediately
end