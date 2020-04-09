#
# Cookbook Name:: hc_tomcat
# Recipe:: fidelity_phix
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
#

### App

if node.run_list?('role[cp-phix-app]')
	template "#{node['hc_tomcat']['tomcat_home']}/conf/Catalina/localhost/employer.xml" do
	  source 'product/phix/cp/employer.xml.erb'
	  mode '0640'
	  owner node['hc_tomcat']['user']
	  group node['hc_tomcat']['group']
	end

	template "#{node['hc_tomcat']['tomcat_home']}/conf/Catalina/localhost/employee.xml" do
	  source 'product/phix/cp/employee.xml.erb'
	  mode '0640'
	  owner node['hc_tomcat']['user']
	  group node['hc_tomcat']['group']
	end

	template "#{node['hc_tomcat']['tomcat_home']}/conf/Catalina/localhost/individual.xml" do
	  source 'product/phix/cp/individual.xml.erb'
	  mode '0640'
	  owner node['hc_tomcat']['user']
	  group node['hc_tomcat']['group']
	end

	template "#{node['hc_tomcat']['tomcat_home']}/conf/Catalina/localhost/broker.xml" do
	  source 'product/phix/cp/broker.xml.erb'
	  mode '0640';
	  owner node['hc_tomcat']['user']
	  group node['hc_tomcat']['group']
	end
end

### batch

if node.run_list?('role[cp-phix-batch]')
	template "#{node['hc_tomcat']['tomcat_home']}/conf/Catalina/localhost/external.xml" do
	  source 'product/phix/cp/external.xml.erb'
	  mode '0640'
	  owner node['hc_tomcat']['user']
	  group node['hc_tomcat']['group']
	end

	template "#{node['hc_tomcat']['tomcat_home']}/conf/Catalina/localhost/exchange-admin.xml" do
	  source 'product/phix/cp/exchange-admin.xml.erb'
	  mode '0640'
	  owner node['hc_tomcat']['user']
	  group node['hc_tomcat']['group']
	end

	template "#{node['hc_tomcat']['tomcat_home']}/conf/Catalina/localhost/cp-reports.xml" do
	  source 'product/phix/cp/cp-reports.xml.erb'
	  mode '0640'
	  owner node['hc_tomcat']['user']
	  group node['hc_tomcat']['group']
	end
end