#
# Cookbook Name:: hc_apache
# Recipe:: virtualhost
#
# Copyright (C) 2015 company
#
# All rights reserved - Do Not Redistribute
#

Chef::Log.info "hc_apache::sso_virtualhost started "
Chef::Log.info 'Including recipe hc_apache::default'
include_recipe 'hc_apache::default'

template "#{node['apache']['dir']}/sites-available/sso.conf" do
  source "product/sso/sso.conf.erb"
  mode 0644
  owner 'root'
  group node['apache']['root_group']
end

link "#{node['apache']['dir']}/sites-enabled/sso.conf" do
  to "#{node['apache']['dir']}/sites-available/sso.conf"
end
Chef::Log.info "hc_apache::arshop_hix_virtualhost finished "
