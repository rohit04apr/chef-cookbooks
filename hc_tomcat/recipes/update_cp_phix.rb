#
# Cookbook Name:: hc_tomcat
# Recipe:: update_cp_phix_jvm
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
#

log 'hc_tomcat::update_cp_phix recipe execution started'

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

template "#{node['hc_tomcat']['tomcat_home']}/conf/context.xml" do
  source 'product/phix/cp/context.xml.erb'
  mode '0640'
  owner node['hc_tomcat']['user']
  group node['hc_tomcat']['group']
end

template "#{node['hc_tomcat']['tomcat_home']}/conf/server.xml" do
  db_dump = data_bag_item(node.chef_environment, "#{node['implementation']}_#{node['product']}")
  source 'product/phix/cp/server.xml.erb'
  mode '0640'
  owner node['hc_tomcat']['user']
  group node['hc_tomcat']['group']
  variables(
    :db_hostname => db_dump['db_hostname'],
    :sid => db_dump['sid'],
    :db_username => db_dump['db_username'],
    :db_password => db_dump['db_password'],
	:de_db_username => db_dump['de_db_username'],
    :de_db_password => db_dump['de_db_password'],
	:port => node['hc_tomcat']['port'],
    :proxy_port => node['hc_tomcat']['proxy_port'],
    :secure => node['hc_tomcat']['secure'],
    :scheme => node['hc_tomcat']['scheme'],
    :ssl_port => node['hc_tomcat']['ssl_port'],
    :ssl_proxy_port => node['hc_tomcat']['ssl_proxy_port'],
    :ajp_port => node['hc_tomcat']['ajp_port'],
    :ajp_redirect_port => node['hc_tomcat']['ajp_redirect_port'],
    :shutdown_port => node['hc_tomcat']['shutdown_port'],
    :max_connections => node['hc_tomcat']['max_connections'],
    :keep_alive_timeout => node['hc_tomcat']['keep_alive_timeout'],
    :connection_timeout => node['hc_tomcat']['connection_timeout'],
    :scimweblogs_dir => node['hc_tomcat']['scimweblogs_dir'],
    :uriencoding => node['hc_tomcat']['uriencoding'],
	:port => node['hc_tomcat']['port'],
	:max_threads => node['hc_tomcat']['max_threads'],
	:config_dir => node['hc_tomcat']['config_dir'],
	:keystore_type => node['hc_tomcat']['keystore_type'],
	:keystore_file => node['hc_tomcat']['keystore_file'],
	:ssl_max_threads => node['hc_tomcat']['ssl_max_threads'],
	:client_auth => node['hc_tomcat']['client_auth'],
	:tomcat_auth => node['hc_tomcat']['tomcat_auth'],
	:ajp_packetsize=> node['hc_tomcat']['ajp_packetsize']
    )
end

service node['hc_tomcat']['base_instance'] do
  action :start
end

log 'hc_tomcat::update_cp_phix recipe execution finished'