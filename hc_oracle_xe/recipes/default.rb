#
# Cookbook Name:: hc_oracle_xe
# Recipe:: default
#
# Copyright 2016, company 
#
# All rights reserved - Do Not Redistribute
#

artfct_user_details = data_bag_item('chef_credentials', 'artifactory')
node.set["oracle-xe"]["url"] = "http://#{artfct_user_details['username']}:#{artfct_user_details['password']}@#{node['hc_oracle_xe']['url']}"
node.set["oracle-xe"]["oracle-password"] = node['hc_oracle_xe']['oracle-password']

Chef::Log.info "oracle-xe:url = #{node['oracle-xe']['url']}"
Chef::Log.info 'hc_oracle_xe::default recipe execution started'
#Chef::Log.info 'hc_oracle_xe::default:: Including recipe hc_oracle-xe::swap'
#include_recipe "hc_oracle_xe::swap"
Chef::Log.info 'hc_oracle_xe::default:: Including recipe oracle-xe::default'
include_recipe "oracle-xe::default"
Chef::Log.info 'hc_oracle_xe::default recipe execution finished'

#Load DB password from databag
passwords = data_bag_item(node.chef_environment, node['product'])
uname = Chef::Config[:node_name].split('.')[0].tr('-','_')
template "createuser" do
  source 'createuser.erb'
  path '/tmp/createuser.sql'
  variables({ :Database_Password => passwords['db_password'],
:Database_Schema => uname} )
  action :create
  notifies :run, 'execute[create-app-user]', :immediately
end


execute 'create-app-user' do
  command "source /u01/app/oracle/product/11.2.0/xe/bin/oracle_env.sh && sqlplus / as sysdba @/tmp/createuser.sql"
  user 'oracle'
  group 'dba' # required
  action :nothing
end
