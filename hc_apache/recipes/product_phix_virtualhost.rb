#
# Cookbook Name:: hc_apache
# Recipe:: virtualhost
#
# Copyright (C) 2015 company
#
# All rights reserved - Do Not Redistribute
#

Chef::Log.info "hc_apache::product_phix_virtualhost started"
Chef::Log.info 'Including recipe hc_apache::default'
include_recipe 'hc_apache::default'

#node[apache]['default_modules']
%w(dev-default.conf dev-default-ssl.conf).each do |conf|
template "#{node['apache']['dir']}/sites-available/#{conf}" do
  source "product/phix/product/#{conf}.erb"
  mode 0644
  owner 'root'
  group node['apache']['root_group']
end
end

Chef::Log.info "hc_apache::product_phix_virtualhost finished"
