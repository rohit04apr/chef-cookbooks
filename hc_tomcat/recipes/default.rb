#
# Cookbook Name:: hc_tomcat
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
#

Chef::Log.info 'hc_tomcat::default recipe execution started'
# Grab and unpack tomcat package
artfct_user_details = data_bag_item('chef_credentials', node['chef_credentials']['artifactory'])
remote_file "/opt/#{node['hc_tomcat']['package_name']}" do
  source "http://#{artfct_user_details['username']}:#{artfct_user_details['password']}@artifactory.demo.company.com/artifactory/chef-repo/tomcat/#{node['hc_tomcat']['package_name']}"
  owner 'root'
  group 'root'
  mode '0755'
end

<<'COMMENT'
user node['hc_tomcat']['user'] do
  #supports :manage_home => true
  uid '2002'
  home '/home/tomcat'
  shell '/bin/bash'
  system true
  action :create
end
COMMENT
execute 'extract_tomcat_tar' do
  command "tar xzvf #{node['hc_tomcat']['package_name']} -C #{node['hc_tomcat']['install_path']}"
  cwd '/opt'
  not_if { ::Dir.exists?("#{node['hc_tomcat']['install_path']}/#{node['hc_tomcat']['tomcat_dir_name']}") }
end

execute "chown-tomcat" do
  cwd '/usr/local'
  command  "chown -R #{node['hc_tomcat']['user']}:#{node['hc_tomcat']['group']} #{node['hc_tomcat']['tomcat_dir_name']}"
  subscribes :run, "link[/etc/tomcat]", :immediately
end

node['hc_tomcat']['remove_dirs'].each do |dir_name|
  directory "#{node['hc_tomcat']['tomcat_home']}/webapps/#{dir_name}" do
    action :delete
    recursive true
  end
end

<<'COMMENT'
execute "chown-tomcat-dir" do
  command "chown -R #{node['hc_tomcat']['user']}:#{node['hc_tomcat']['group']} #{node['hc_tomcat']['tomcat_dir_name']}"
  user "root"
end

service 'tomcat' do
  action :stop
  #only_if { ::File.exists?("/etc/init.d/tomcat") }
  only_if { ::File.exists?("/var/local/tomcat.pid") }
end
COMMENT

template "/etc/init.d/tomcat#{node['hc_tomcat']['base_version']}" do
  source 'tomcat.erb'
  mode '0755'
  owner node['hc_tomcat']['user']
  group node['hc_tomcat']['group']
  #owner 'root'
  #group 'root'
end

link "/etc/init.d/tomcat" do
  to "/etc/init.d/tomcat#{node['hc_tomcat']['base_version']}"
end

link "/usr/local/tomcat" do
  to "/usr/local/#{node['hc_tomcat']['tomcat_dir_name']}"
end

link "/etc/tomcat" do
  to "/usr/local/#{node['hc_tomcat']['tomcat_dir_name']}/conf"
end

# SmartOS doesn't support multiple instances
template "#{node['hc_tomcat']['tomcat_home']}/bin/setenv.sh" do
  source 'setenv.sh.erb'
  mode '0644'
  owner node['hc_tomcat']['user']
  group node['hc_tomcat']['group']
end

def create_service(instance)
  service instance do
    case node['platform_family']
    when 'rhel', 'fedora'
      service_name instance
      supports restart: true, status: true
    else
      service_name instance
    end
    action [:start, :enable]
    notifies :run, "execute[wait for #{instance}]", :immediately
    retries 1
    retry_delay 2
  end
end

if node['hc_tomcat']['run_base_instance']
  hc_tomcat_instance 'base' do
    port node['hc_tomcat']['port'].to_i
    proxy_port node['hc_tomcat']['proxy_port']
    proxy_name node['hc_tomcat']['proxy_name']
    secure node['hc_tomcat']['secure']
    scheme node['hc_tomcat']['scheme']
    ssl_port node['hc_tomcat']['ssl_port']
    ssl_proxy_port node['hc_tomcat']['ssl_proxy_port']
    ajp_port node['hc_tomcat']['ajp_port']
    ajp_redirect_port node['hc_tomcat']['ajp_redirect_port']
    shutdown_port node['hc_tomcat']['shutdown_port']
    max_connections node['hc_tomcat']['max_connections']
    keep_alive_timeout node['hc_tomcat']['keep_alive_timeout']
    connection_timeout node['hc_tomcat']['connection_timeout']
    scimweblogs_dir node['hc_tomcat']['scimweblogs_dir']
  end
  instance = node['hc_tomcat']['base_instance']
  Chef::Log.info "hc_tomcat::default instance value is #{instance}"
  create_service(instance)
end

node['hc_tomcat']['instances'].each do |name, attrs|
  tomcat_instance name do
    port attrs['port']
    proxy_port attrs['proxy_port']
    proxy_name attrs['proxy_name']
    secure attrs['secure']
    scheme attrs['scheme']
    ssl_port attrs['ssl_port']
    ssl_proxy_port attrs['ssl_proxy_port']
    ajp_port attrs['ajp_port']
    ajp_redirect_port attrs['ajp_redirect_port']
    shutdown_port attrs['shutdown_port']
    config_dir attrs['config_dir']
    log_dir attrs['log_dir']
    scimweblogs_dir attrs['scimweblogs_dir']
    work_dir attrs['work_dir']
    context_dir attrs['context_dir']
    webapp_dir attrs['webapp_dir']
    catalina_options attrs['catalina_options']
    java_options attrs['java_options']
    use_security_manager attrs['use_security_manager']
    authbind attrs['authbind']
    max_threads attrs['max_threads']
    ssl_max_threads attrs['ssl_max_threads']
    ssl_cert_file attrs['ssl_cert_file']
    ssl_key_file attrs['ssl_key_file']
    ssl_chain_files attrs['ssl_chain_files']
    keystore_file attrs['keystore_file']
    keystore_type attrs['keystore_type']
    truststore_file attrs['truststore_file']
    truststore_type attrs['truststore_type']
    certificate_dn attrs['certificate_dn']
    loglevel attrs['loglevel']
    tomcat_auth attrs['tomcat_auth']
    client_auth attrs['client_auth']
    user attrs['user']
    group attrs['group']
    home attrs['home']
    base attrs['base']
    tmp_dir attrs['tmp_dir']
    lib_dir attrs['lib_dir']
    endorsed_dir attrs['endorsed_dir']
    ajp_packetsize attrs['ajp_packetsize']
    uriencoding attrs['uriencoding']
    max_connections attrs['max_connections']
    keep_alive_timeout attrs['keep_alive_timeout']
    connection_timeout attrs['connection_timeout']
  end

#instance = "#{node['hc_tomcat']['base_instance']}-#{name}"
instance = node['hc_tomcat']['base_instance']
  create_service(instance)
end

execute "wait for #{instance}" do
  command 'sleep 5'
  action :nothing
end
#service "tomcat" do
#  action :start
  
#end

Chef::Log.info 'hc_tomcat::default recipe execution finished'

