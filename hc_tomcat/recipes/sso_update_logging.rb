log 'Applying sso tomcat log standardization..'
%w(/var/log/sso/scimweb_logs /usr/local/tomcat/logback).each do |dir|
  directory dir do
    action :create
    mode '2775'
    recursive true
    user 'tomcat'
    group 'tomcat'
  end
end

template "#{node['hc_tomcat']['tomcat_home']}/logback/logback.properties" do
  source 'product/sso/logback.properties.erb'
  mode '0644'
  owner node['hc_tomcat']['user']
  group node['hc_tomcat']['group']
end

template "#{node['hc_tomcat']['tomcat_home']}/bin/setenv.sh" do
  source 'product/sso/setenv.sh.erb'
  mode '0644'
  owner node['hc_tomcat']['user']
  group node['hc_tomcat']['group']
end

service 'tomcat' do
  action :restart
end

log 'SSO tomcat log standardization finished...'