#
# Cookbook Name:: hc_apache
# Recipe:: virtualhost
#
# Copyright (C) 2015 company
#
# All rights reserved - Do Not Redistribute
#

Chef::Log.info 'hc_apache::virtualhost recipe execution started'

Chef::Log.info 'Including recipe hc_apache::default'
include_recipe 'hc_apache::default'


def create_virtualhost_file(template_file, file)
       Chef::Log.info "hc_apache::virtualhost  Inside create_virtualhost_file method. Template file name is #{template_file} and file name is #{file}"
	template "#{node['apache']['dir']}/sites-available/#{file}" do
	  source "product/#{template_file}"
	  mode 0644
	  owner 'root'
      group node['apache']['root_group']
	end

	link "#{node['apache']['dir']}/sites-enabled/#{file}" do
	to "#{node['apache']['dir']}/sites-available/#{file}"
	  end
end


Chef::Log.info node.roles
case
	when node.roles.include?('sso')
	 template_file = "sso/sso.conf.erb"
	 vh_file = "sso.conf"
	 create_virtualhost_file("#{template_file}", "#{vh_file}")
end
