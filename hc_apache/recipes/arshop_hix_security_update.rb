#
# Cookbook Name:: hc_apache
# Recipe:: arshop_hix_security_update
#
# Copyright (C) 2016 company
#
# All rights reserved - Do Not Redistribute
#

log "hc_apache::arshop_hix_security_update started "

template "#{node['apache']['dir']}/sites-available/hix.conf" do
  source "product/hix/arshop/hix.conf.erb"
  mode 0644
  owner 'root'
  group node['apache']['root_group']
end

link "#{node['apache']['dir']}/sites-enabled/hix.conf" do
  to "#{node['apache']['dir']}/sites-available/hix.conf"
end

template "#{node['apache']['conf_dir']}/security" do
  source "product/hix/arshop/security.erb"
  mode 0644
  owner 'root'
  group node['apache']['root_group']
end

template 'apache2.conf' do
  if platform_family?('rhel', 'fedora', 'arch', 'freebsd')
    path "#{node['apache']['conf_dir']}/httpd.conf"
  elsif platform_family?('debian')
    path "#{node['apache']['conf_dir']}/apache2.conf"
  elsif platform_family?('suse')
    path "#{node['apache']['conf_dir']}/httpd.conf"
  end
  action :create
  source "product/hix/arshop/httpd.conf.erb"
  owner 'root'
  group node['apache']['root_group']
  mode '0644'
  notifies :reload, 'service[apache2]', :delayed
end

log "hc_apache::arshop_hix_security_update finished "
