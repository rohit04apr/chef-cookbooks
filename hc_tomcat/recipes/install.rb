
#
# Cookbook Name:: hc_tomcat
# Recipe:: install
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
#


log 'Testing tomcat on rhel 7'

hc_tomcat_configure 'tomcat' do
  version node['hc_tomcat']['base_version']
  install_path node['hc_tomcat']['install_path']
  exclude_docs true
  exclude_examples true
  exclude_manager true
  exclude_hostmanager true
  template_source 'phix/cp'
  action :install
end

tomcat_service '8' do
  install_path '/usr/local/tomcat'
  action :start
  env_vars [
  	         {'CATALINA_PID' => "#{node['hc_tomcat']['tomcat_home']}/tomcat.pid" }, 
             {'CATALINA_HOME' => "#{node['hc_tomcat']['home']}"},
             {'CATALINA_OPTS' => "#{node['hc_tomcat']['catalina_options']}"},
             {'CATALINA_BASE' => "#{ node['hc_tomcat']['base']}"},
             {'JAVA_HOME' => "#{node['hc_java']['java_home']}"},
             {'JAVA_OPTS' => "#{node['hc_tomcat']['java_options']}"}             
           ]
end

template "/etc/systemd/system/tomcat.service" do
  source "service_rhel7.erb"
  owner 'tomcat'
  group 'tomcat'
  mode '0755'
end

log 'Creating symlinks for service'
#@major_version ||= node['hc_tomcat']['base_version'].split('.')[0]
major_version = node['hc_tomcat']['base_version']
log "Major version is #{major_version}"
#@symlinks = ['/etc/init.d/tomcat', '/etc/systemd/system/tomcat.service', '/etc/init/tomcat']
#@link_dst = ["/etc/init.d/tomcat_#{major_version}", "/etc/systemd/system/tomcat_#{major_version}.service",  "/etc/init/tomcat_#{major_version}.conf"]
#@symlinks.zip @link_dst
#@symlinks.zip(@link_dst).each do |symlink, destination|
#  link symlink do
#    to destination
#    only_if { ::File.exist?("#{destination}") }
#  end
#end
#@symlinks = ''
#@link_dst = ''
@symlinks = ['/etc/tomcat', '/usr/local/tomcat']
@link_dst = ["#{node['hc_tomcat']['install_path']}/#{node['hc_tomcat']['tomcat_dir_name']}/conf", "#{node['hc_tomcat']['install_path']}/#{node['hc_tomcat']['tomcat_dir_name']}"]
@symlinks.zip @link_dst
@symlinks.zip(@link_dst).each do |symlink, destination|
  link symlink do
    to destination
    only_if { ::File.directory?("#{destination}") }
  end
end

template "#{node['hc_tomcat']['config_dir']}/logging.properties" do
  source "product/phix/cp/logging.properties.erb"
  owner 'tomcat'
  group 'tomcat'
  mode '0644'
end

execute 'Load systemd unit file' do
  command 'systemctl daemon-reload'
  action :run
end

service 'tomcat' do
  supports status: true
  action :start
end
