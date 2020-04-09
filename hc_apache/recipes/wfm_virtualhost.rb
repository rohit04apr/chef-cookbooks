#
# Cookbook Name:: hc_apache
# Recipe:: virtualhost
#
# Copyright (C) 2015 company
#
# All rights reserved - Do Not Redistribute
#

Chef::Log.info "hc_apache::wfm_virtualhost started "
Chef::Log.info 'Including recipe hc_apache::default'
include_recipe 'hc_apache::default'
%w(default.conf arkansas.conf).each do |conf|
  template "#{node['apache']['dir']}/sites-available/#{conf}" do
    source "product/wfm/#{conf}.erb"
    mode 0644
    owner 'root'
    group 'root'
  end

  link "#{node['apache']['dir']}/sites-enabled/#{conf}" do
    to "#{node['apache']['dir']}/sites-available/#{conf}"
  end
end
#<<'COMMENT'
node['hc_apache']['wfm']['ws']['dirs'].each do |dir|
  directory dir do
    recursive true
    action :create
  end
end

Chef::Log.info "hc_apache::wfm_virtualhost finished "
