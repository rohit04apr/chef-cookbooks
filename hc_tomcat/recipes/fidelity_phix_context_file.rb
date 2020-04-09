#
# Cookbook Name:: hc_tomcat
# Recipe:: fidelity_phix
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
#

### App

if node.run_list?('role[fidelity-phix-app]')
  template "#{node['hc_tomcat']['tomcat_home']}/conf/Catalina/localhost/employer.xml" do
    source 'product/phix/fidelity/employer.xml.erb'
    mode '0640'
    owner node['hc_tomcat']['user']
    group node['hc_tomcat']['group']
  end

  template "#{node['hc_tomcat']['tomcat_home']}/conf/Catalina/localhost/employee.xml" do
    source 'product/phix/fidelity/employee.xml.erb'
    mode '0640'
    owner node['hc_tomcat']['user']
    group node['hc_tomcat']['group']
  end

  template "#{node['hc_tomcat']['tomcat_home']}/conf/Catalina/localhost/individual.xml" do
    source 'product/phix/fidelity/individual.xml.erb'
    mode '0640'
    owner node['hc_tomcat']['user']
    group node['hc_tomcat']['group']
  end

  template "#{node['hc_tomcat']['tomcat_home']}/conf/Catalina/localhost/broker.xml" do
    source 'product/phix/fidelity/broker.xml.erb'
    mode '0640'
    owner node['hc_tomcat']['user']
    group node['hc_tomcat']['group']
  end
end

### batch
if node.run_list?('role[fidelity-phix-batch]')
  template "#{node['hc_tomcat']['tomcat_home']}/conf/Catalina/localhost/external.xml" do
    source 'product/phix/fidelity/external.xml.erb'
    mode '0640'
    owner node['hc_tomcat']['user']
    group node['hc_tomcat']['group']
  end

  template "#{node['hc_tomcat']['tomcat_home']}/conf/Catalina/localhost/exchange-admin.xml" do
    source 'product/phix/fidelity/exchange-admin.xml.erb'
    mode '0640'
    owner node['hc_tomcat']['user']
    group node['hc_tomcat']['group']
  end

  template "#{node['hc_tomcat']['tomcat_home']}/conf/Catalina/localhost/fidelity-sso.xml" do
    source 'product/phix/cp/fidelity-sso.xml.erb'
    mode '0640'
    owner node['hc_tomcat']['user']
    group node['hc_tomcat']['group']
  end

  template "#{node['hc_tomcat']['tomcat_home']}/conf/Catalina/localhost/fidelity-reports.xml" do
    source 'product/phix/cp/fidelity-reports.xml.erb'
    mode '0640'
    owner node['hc_tomcat']['user']
    group node['hc_tomcat']['group']
  end
end