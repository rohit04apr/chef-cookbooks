#
# Cookbook Name:: hc_apacheds
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
#

begin
Chef::Log.info 'hc_apacheds::default recipe execution started'

#include_recipe 'hc_java'
#include_recipe 'hc_users'
#Get artifactory credentials from databag
artfct_user_details = data_bag_item(node['hc_apacheds']['chef']['databag']['name'], node['hc_apacheds']['chef']['databag']['id'])

#Create temp directory
directory node['hc_apacheds']['install']['tmp'] do
  owner node['hc_apacheds']['user']
  group node['hc_apacheds']['group']
  mode '0755'
  action :create
  not_if { ::File.exists?("#{node['hc_apacheds']['install']['path']}/apacheds-#{node['hc_apacheds']['version']}/libs/apacheds-service-#{node['hc_apacheds']['version']}.jar") }
end

#Create directory if requried
node['hc_apacheds']['config'].each do |dir|
  directory "#{dir}" do
    owner 'idm'
    group 'idm'
    mode '2775'
    recursive true
    action :create
  end
end
#Install openldap-clients
package 'openldap-clients.x86_64' do
end

#Download tar package from artifactory
remote_file node['hc_apacheds']['package']['name'] do
  source "http://#{artfct_user_details['username']}:#{artfct_user_details['password']}@#{node['hc_apacheds']['package']['url']}"
  mode '0755'
  path "#{node['hc_apacheds']['install']['tmp']}/#{node['hc_apacheds']['package']['name']}"
  action :create_if_missing
  not_if { ::File.exists?("#{node['hc_apacheds']['install']['path']}/apacheds-#{node['hc_apacheds']['version']}/libs/apacheds-service-#{node['hc_apacheds']['version']}.jar") }
  notifies :stop, 'service[apacheds]', :immediately
end

#Extract apacheds tar
execute 'extract_apacheds_tar' do
  command "tar xzvf #{node['hc_apacheds']['package']['name']} -C #{node['hc_apacheds']['install']['path']}"
  cwd node['hc_apacheds']['install']['tmp']
  not_if { ::Dir.exists?("#{node['hc_apacheds']['install']['path']}/apacheds-#{node['hc_apacheds']['version']}") }
  notifies :run, 'execute[chown-apacheds]', :immediately
  notifies :create, 'template[apacheds_servicefile]', :immediately
  notifies :create, "file[#{node['hc_apacheds']['install']['path']}/apacheds-#{node['hc_apacheds']['version']}/bin/apacheds.sh]", :immediately
  notifies :create, "link[#{node['hc_apacheds']['install']['path']}/apacheds]", :immediately
  notifies :create, "template[#{node['hc_apacheds']['install']['path']}/apacheds-#{node['hc_apacheds']['version']}/bin/setenv.sh]",:immediately
  notifies :start, 'service[apacheds]', :immediately
  notifies :run, 'execute[check_service_started]', :immediately
  notifies :create, 'template[changelog]', :immediately
  notifies :create, 'template[journal]', :immediately
  notifies :create, 'template[passwordreset]', :immediately
  notifies :stop, 'service[apacheds]', :immediately
  notifies :run, 'ruby_block[sleep]', :immediately
  notifies :start, 'service[apacheds]', :immediately
end

#Make apacheds.sh exceutable
file "#{node['hc_apacheds']['install']['path']}/apacheds-#{node['hc_apacheds']['version']}/bin/apacheds.sh" do
  mode '0755'
  action :nothing
end

#Change owner and group after extract
execute 'chown-apacheds' do
  command  "chown -R #{node['hc_apacheds']['user']}:#{node['hc_apacheds']['group']} #{node['hc_apacheds']['install']['path']}/apacheds-#{node['hc_apacheds']['version']}"
  action :nothing
end

#Create symlink for current used verison
link "#{node['hc_apacheds']['install']['path']}/apacheds" do
  to  "#{node['hc_apacheds']['install']['path']}/apacheds-#{node['hc_apacheds']['version']}"
  only_if "test -d #{node['hc_apacheds']['install']['path']}/apacheds-#{node['hc_apacheds']['version']}"
end

template "apacheds_servicefile" do
  source 'apacheds.erb'
  mode '0755'
  path '/etc/init.d/apacheds'
end

#Create symlink for current used verison
link "#{node['hc_apacheds']['install']['path']}/apacheds-#{node['hc_apacheds']['version']}/bin/apacheds" do
  to  "#{node['hc_apacheds']['install']['path']}/apacheds-#{node['hc_apacheds']['version']}/bin/apacheds.sh"
  mode 0755
  owner node['hc_apacheds']['user']
  group node['hc_apacheds']['group']
end

#Create service file
#Create setenv file for overrides
template "#{node['hc_apacheds']['install']['path']}/apacheds-#{node['hc_apacheds']['version']}/bin/setenv.sh" do
  source 'setenv.sh.erb'
  mode '0755'
  owner node['hc_apacheds']['user']
  group node['hc_apacheds']['group']
  action :nothing
end

service 'apacheds' do
  action :nothing
  supports :start => true, :stop => true, :restart => true
  only_if { ::File.exists?('/etc/init.d/apacheds') }
end

ruby_block "sleep" do
  block do
    sleep(40)
  end
  action :nothing
end

#Change permission to user
execute 'chown-apacheds' do
  command  "chown -R #{node['hc_apacheds']['user']}:#{node['hc_apacheds']['group']} #{node['hc_apacheds']['install']['path']}/apacheds-#{node['hc_apacheds']['version']}"
  action :nothing
end

#Load passords from env specific data bag
passwords = data_bag_item(node.chef_environment, node['product'])

#LDiff file for password reset
template "passwordreset" do
  source 'passwordreset.ldiff.erb'
  path "#{node['hc_apacheds']['install']['tmp']}/passwordreset.ldiff"
  variables({ :ldappassword => passwords['ldap_password']} )
  action :nothing
  notifies :run, 'execute[passwordreset]', :immediately
end

#LDiff file for enable journal
template "journal" do
  source 'journal.ldiff.erb'
  path "#{node['hc_apacheds']['install']['tmp']}/journal.ldiff"
  action :nothing
  notifies :run, 'execute[journal]', :immediately
end

#LDiff file for enable changelog
template "changelog" do
  source 'changelog.ldiff.erb'
  path "#{node['hc_apacheds']['install']['tmp']}/changelog.ldiff"
  action :nothing
  notifies :run, 'execute[changelog]', :immediately
end

# Run Ldiffs
execute 'changelog' do
  command  "ldapmodify -h localhost -p 10389 -D uid=admin,ou=system -w secret -f #{node['hc_apacheds']['install']['tmp']}/changelog.ldiff"
  action :nothing
end

execute 'journal' do
  command  "ldapmodify -h localhost -p 10389 -D uid=admin,ou=system -w secret -f #{node['hc_apacheds']['install']['tmp']}/journal.ldiff"
  action :nothing
end

execute 'passwordreset' do
  command  "ldapmodify -h localhost -p 10389 -D uid=admin,ou=system -w secret -f #{node['hc_apacheds']['install']['tmp']}/passwordreset.ldiff"
  action :nothing
end

execute 'check_service_started' do
  command  "until ldapsearch -xLLL -H 'ldap://localhost:10389' -s one -A -D uid=admin,ou=system -w secret >> /dev/null; do   echo 'Service not running, retrying in 10 seconds...'; sleep 10; done"
  action :nothing
  timeout node['hc_users']['execute']['timeout']
end


group 'idm' do
  action :modify
  members 'hcbuild'
  append true
end

ensure
  #Cleanup downloaded
  Chef::Log.info "hc_josso::ce Cleaning up temp folder......"
  directory node['hc_apacheds']['install']['tmp'] do
    action :delete
    recursive true
    only_if "test -d #{node['hc_apacheds']['install']['tmp']}"
  end
end
Chef::Log.info 'hc_apacheds::default recipe execution finished'
