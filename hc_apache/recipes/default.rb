#
# Cookbook Name:: hc_apache
# Recipe:: default
#
# Copyright (C) 2015 company
#
# All rights reserved - Do Not Redistribute
#

Chef::Log.info 'hc_apache::default recipe execution started'
chef_gem "chef-rewind"
require 'chef/rewind'
Chef::Log.info 'Checking fir RHEL 6.x'
if node['platform_family'] == "rhel"
	if node['platform_version'] =~ /6.*/
		#Get artifactory credentials from databag
		artfct_user_details = data_bag_item('chef_credentials', node['chef_credentials']['artifactory'])

		#Download ce jar from artifactory
		remote_file '/etc/yum.repos.d/epel-httpd24.repo' do
			source "http://#{artfct_user_details['username']}:#{artfct_user_details['password']}@#{node['hc_apache']['apache2.4']['repo']}"
			mode '0755'
			action :create_if_missing
		end
	end
end

package 'apache2' do
  package_name node['apache']['package']
  default_release node['apache']['default_release'] unless node['apache']['default_release'].nil?
end

%w(sites-available sites-enabled mods-available mods-enabled conf-available conf-enabled).each do |dir|
  directory "#{node['apache']['dir']}/#{dir}" do
    mode '0755'
    owner 'root'
    group node['apache']['root_group']
  end
end

%w(default default.conf 000-default 000-default.conf).each do |site|
  link "#{node['apache']['dir']}/sites-enabled/#{site}" do
    action :delete
    not_if { site == "#{node['apache']['default_site_name']}.conf" && node['apache']['default_site_enabled'] }
  end

  file "#{node['apache']['dir']}/sites-available/#{site}" do
    action :delete
    backup false
    not_if { site == "#{node['apache']['default_site_name']}.conf" && node['apache']['default_site_enabled'] }
  end
end

directory "#{node['apache']['dir']}/conf.d" do
  action :delete
  recursive true
end

directory node['apache']['log_dir'] do
  mode '0755'
  recursive true
end

# perl is needed for the a2* scripts
package node['apache']['perl_pkg']

%w(a2ensite a2dissite a2enmod a2dismod a2enconf a2disconf).each do |modscript|
  link "/usr/sbin/#{modscript}" do
    action :delete
    only_if { ::File.symlink?("/usr/sbin/#{modscript}") }
  end

  template "/usr/sbin/#{modscript}" do
    source "#{modscript}.erb"
    mode '0700'
    owner 'root'
    group node['apache']['root_group']
    action :create
  end
end

unless platform_family?('debian')
  cookbook_file '/usr/local/bin/apache2_module_conf_generate.pl' do
    source 'apache2_module_conf_generate.pl'
    mode '0755'
    owner 'root'
    group node['apache']['root_group']
  end

  execute 'generate-module-list' do
    command "/usr/local/bin/apache2_module_conf_generate.pl #{node['apache']['lib_dir']} #{node['apache']['dir']}/mods-available"
    action :nothing
  end

  # enable mod_deflate for consistency across distributions
  include_recipe 'apache2::mod_deflate'
end

if platform_family?('freebsd')

  directory "#{node['apache']['dir']}/Includes" do
    action :delete
    recursive true
  end

  directory "#{node['apache']['dir']}/extra" do
    action :delete
    recursive true
  end
end

if platform_family?('suse')

  directory "#{node['apache']['dir']}/vhosts.d" do
    action :delete
    recursive true
  end

  %w(charset.conv default-vhost.conf default-server.conf default-vhost-ssl.conf errors.conf listen.conf mime.types mod_autoindex-defaults.conf mod_info.conf mod_log_config.conf mod_status.conf mod_userdir.conf mod_usertrack.conf uid.conf).each do |file|
    file "#{node['apache']['dir']}/#{file}" do
      action :delete
      backup false
    end
  end
end

%W(
  #{node['apache']['dir']}/ssl
  #{node['apache']['cache_dir']}
).each do |path|
  directory path do
    mode '0755'
    owner 'root'
    group node['apache']['root_group']
  end
end

directory node['apache']['lock_dir'] do
  mode '0755'
  if node['platform_family'] == 'debian' && node['apache']['version'] == '2.2'
    owner node['apache']['user']
  else
    owner 'root'
  end
  group node['apache']['root_group']
end

# Set the preferred execution binary - prefork or worker
template "/etc/sysconfig/#{node['apache']['package']}" do
  source 'etc-sysconfig-httpd.erb'
  owner 'root'
  group node['apache']['root_group']
  mode '0644'
  only_if  { platform_family?('rhel', 'fedora', 'suse') }
end

template "#{node['apache']['dir']}/envvars" do
  source 'envvars.erb'
  owner 'root'
  group node['apache']['root_group']
  mode '0644'
  only_if  { platform_family?('debian') }
end

include_recipe 'apache2::default'
unwind "template[apache2.conf]"

template 'apache2.conf' do
  if platform_family?('rhel', 'fedora', 'arch', 'freebsd')
    path "#{node['apache']['conf_dir']}/httpd.conf"
  elsif platform_family?('debian')
    path "#{node['apache']['conf_dir']}/apache2.conf"
  elsif platform_family?('suse')
    path "#{node['apache']['conf_dir']}/httpd.conf"
  end
  action :create
  source 'apache2.conf.erb'
  owner 'root'
  group node['apache']['root_group']
  mode '0644'
  notifies :reload, 'service[apache2]', :immediately
end

%w(security charset).each do |conf|
  apache_conf conf do
    enable true
  end
end

apache_conf 'ports' do
  enable false
  conf_path node['apache']['dir']
end

if node['apache']['version'] == '2.4'
  if node['apache']['mpm_support'].include?(node['apache']['mpm'])
    include_recipe "apache2::mpm_#{node['apache']['mpm']}"
  else
    Chef::Log.warn("apache2: #{node['apache']['mpm']} module is not supported and must be handled separately!")
  end
end

node['apache']['default_modules'].each do |mod|
  module_recipe_name = mod =~ /^mod_/ ? mod : "mod_#{mod}"
  include_recipe "apache2::#{module_recipe_name}"
end

apache_service_name = node['apache']['service_name']

service 'apache2' do
  service_name apache_service_name
  case node['platform_family']
  when 'rhel'
    restart_command "/sbin/service #{apache_service_name} restart && sleep 1" if node['apache']['version'] == '2.2'
    reload_command "/sbin/service #{apache_service_name} reload"
  when 'debian'
    provider Chef::Provider::Service::Debian
  when 'arch'
    service_name apache_service_name
  end
  supports [:start, :restart, :reload, :status]
  action [:enable, :start]
  only_if "#{node['apache']['binary']} -t", :environment => { 'APACHE_LOG_DIR' => node['apache']['log_dir'] }, :timeout => 10
end

directory "#{node['apache']['dir']}/htdocs" do
  mode '0755'
  owner 'root'
  group node['apache']['root_group']
end