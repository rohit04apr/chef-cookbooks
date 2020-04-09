#
# Cookbook Name:: hc_tomcat
# Recipe:: update_fidelity_phix
#
# Copyright (c) 2016 company, All Rights Reserved.
#
log 'hc_tomcat::update_fidelity_phix recipe execution started'

service node['hc_tomcat']['base_instance'] do
  action :stop
end

template "#{node['hc_tomcat']['tomcat_home']}/conf/context.xml" do
  db_dump = data_bag_item(node.chef_environment, "#{node['implementation']}_#{node['product']}")
  source 'product/phix/fidelity/context.xml.erb'
  mode '0640'
  owner node['hc_tomcat']['user']
  group node['hc_tomcat']['group']
  variables(
    :db_hostname => db_dump['db_hostname'],
    :sid => db_dump['sid'],
    :db_username => db_dump['db_username'],
    :db_password => db_dump['db_password']
    )
end

template "#{node['hc_tomcat']['tomcat_home']}/bin/setenv.sh" do
  source 'product/phix/fidelity/setenv.sh.erb'
  mode '0644'
  owner node['hc_tomcat']['user']
  group node['hc_tomcat']['group']
end

service node['hc_tomcat']['base_instance'] do
  action :start
end

log 'hc_tomcat::update_fidelity_phix recipe execution finished'