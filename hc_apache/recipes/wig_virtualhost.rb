#
# Cookbook Name:: hc_apache
# Recipe:: virtualhost
#
# Copyright (C) 2015 company
#
# All rights reserved - Do Not Redistribute
#

Chef::Log.info "hc_apache::wig_virtualhost started "
Chef::Log.info 'Including recipe hc_apache::default'
include_recipe 'hc_apache::default'

template "#{node['apache']['dir']}/sites-available/wig.conf" do
  source "product/wig/wig.conf.erb"
  mode 0644
  owner 'root'
  group node['apache']['root_group']
end

link "#{node['apache']['dir']}/sites-enabled/wig.conf" do
  to "#{node['apache']['dir']}/sites-available/wig.conf"
end
Chef::Log.info "hc_apache::wig_virtualhost finished "
