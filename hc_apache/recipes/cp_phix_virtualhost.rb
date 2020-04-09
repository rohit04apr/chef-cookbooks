#
# Cookbook Name:: hc_apache
# Recipe:: virtualhost
#
# Copyright (C) 2015 company
#
# All rights reserved - Do Not Redistribute
#

Chef::Log.info "hc_apache::cp_phix_virtualhost started "
Chef::Log.info 'Including recipe hc_apache::default'
include_recipe 'hc_apache::default'

#node[apache]['default_modules']
%w(cp_phix.conf external-integration.conf cp-portals.conf common.conf).each do |conf|
  template "#{node['apache']['dir']}/sites-available/#{conf}" do
    source "product/phix/cp/#{conf}.erb"
    mode 0644
    owner 'root'
    group node['apache']['root_group']
  end
end

link "#{node['apache']['dir']}/sites-enabled/cp_phix.conf" do
  to "#{node['apache']['dir']}/sites-available/cp_phix.conf"
end
#<<'COMMENT'
node['hc_apache']['phix']['cp']['dirs'].each do |dir|
  directory dir do
    owner 'tomcat'
    group 'tomcat'
    mode '2775'
    recursive true
    action :create
  end
end
#COMMENT
Chef::Log.info "hc_apache::cp_phix_virtualhost finished "
