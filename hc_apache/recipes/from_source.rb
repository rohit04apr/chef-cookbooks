#
# Cookbook Name:: hc_apache
# Recipe:: from_source
#
# Copyright (C) 2015 company
#
# All rights reserved - Do Not Redistribute
#


artfct_user_details = data_bag_item('chef_credentials', node['chef_credentials']['artifactory'])

# Installing related package
if node['platform_family'] == "rhel"
  package ['openssl-devel', 'pcre-devel']  do
    action :install
  end
elsif node['platform_family'] == "debian"
  package ['build-essential']  do
    action :install
  end
end

remote_file "#{node['hc_apache']['src_path']}/#{node['hc_apache']['package_name']}.tar.bz2" do
   source "http://#{artfct_user_details['username']}:#{artfct_user_details['password']}@#{node['hc_apache']['url']}"
   owner 'root'
   group 'root'
   mode '0755'
end

remote_file "#{node['hc_apache']['src_path']}/#{node['hc_apache']['apr_package_name']}.tar.gz" do
   source "http://#{artfct_user_details['username']}:#{artfct_user_details['password']}@#{node['hc_apache']['apr_url']}"
   owner 'root'
   group 'root'
   mode '0755'
end


remote_file "#{node['hc_apache']['src_path']}/#{node['hc_apache']['apr_util_package_name']}.tar.gz" do
   source "http://#{artfct_user_details['username']}:#{artfct_user_details['password']}@#{node['hc_apache']['apr_util_url']}"
   owner 'root'
   group 'root'
   mode '0755'
end

execute 'untar_files' do
  cwd "#{node['hc_apache']['src_path']}/"
  command <<-EOH
  tar -xvf #{node['hc_apache']['package_name']}.tar.bz2; tar -xvf #{node['hc_apache']['apr_package_name']}.tar.gz; tar -xvf #{node['hc_apache']['apr_util_package_name']}.tar.gz   
 EOH
  not_if { ::Dir.exists?("#{node['hc_apache']['src_path']}/#{node['hc_apache']['package_name']}") }
end


execute 'set_apr' do
  cwd "#{node['hc_apache']['src_path']}/"
  command <<-EOH
  mv -f #{node['hc_apache']['src_path']}/#{node['hc_apache']['apr_package_name']} #{node['hc_apache']['src_path']}/#{node['hc_apache']['package_name']}/srclib/apr; mv #{node['hc_apache']['src_path']}/#{node['hc_apache']['apr_util_package_name']} #{node['hc_apache']['src_path']}/#{node['hc_apache']['package_name']}/srclib/apr-util
 EOH
  not_if { ::Dir.exists?("#{node['hc_apache']['src_path']}/#{node['hc_apache']['package_name']}/srclib/apr-util") }
end

remote_file "#{node['hc_apache']['src_path']}/#{node['hc_apache']['pcre_name']}.tar.gz" do
   source "http://#{artfct_user_details['username']}:#{artfct_user_details['password']}@#{node['hc_apache']['pcre_url']}"
   owner 'root'
   group 'root'
   mode '0755'
end

execute 'pcre_untar_files' do
  cwd "#{node['hc_apache']['src_path']}/"
  command <<-EOH
  tar -xvf #{node['hc_apache']['pcre_name']}.tar.gz;
 EOH
  not_if { ::Dir.exists?("#{node['hc_apache']['src_path']}/#{node['hc_apache']['pcre_name']}") }
end

execute 'pcre-configure' do
  cwd "#{node['hc_apache']['src_path']}/#{node['hc_apache']['pcre_name']}"
  command "./configure --prefix=/usr/local/pcre"
  not_if { ::File.exists?("#{node['hc_apache']['init_path']}") }
end

execute 'pcre-make' do
  cwd "#{node['hc_apache']['src_path']}/#{node['hc_apache']['pcre_name']}"
  command "make"
  not_if { ::File.exists?("#{node['hc_apache']['init_path']}") }
end

execute 'pcre-make-install' do
  cwd "#{node['hc_apache']['src_path']}/#{node['hc_apache']['pcre_name']}"
  command "make install"
  not_if { ::File.exists?("#{node['hc_apache']['init_path']}") }
end

execute 'configure' do
  cwd "#{node['hc_apache']['src_path']}/#{node['hc_apache']['package_name']}"
  command "./configure --sysconfdir=/etc/apache2  #{node['hc_apache']['allmodules']} --with-pcre=/usr/local/pcre"
  not_if { ::File.exists?("#{node['hc_apache']['init_path']}") }
end

execute 'make' do
  cwd "#{node['hc_apache']['src_path']}/#{node['hc_apache']['package_name']}"
  command "make"
  not_if { ::File.exists?("#{node['hc_apache']['init_path']}") }
end

execute 'make-install' do
  cwd "#{node['hc_apache']['src_path']}/#{node['hc_apache']['package_name']}"
  command "make install"
  not_if { ::File.exists?("#{node['hc_apache']['init_path']}") }
end

%w(sites-available sites-enabled mods-available mods-enabled conf-available conf-enabled).each do |dir|
  directory "#{node['hc_apache']['home']}/#{dir}" do
    mode '0755'
    owner 'root'
    group node['apache']['root_group']
  end
end

template "#{node['hc_apache']['init_path']}" do
  source 'httpd.conf.erb'
  owner 'root'
  group 'root'
  mode '0777'
end

node['hc_apache']['mod'].each do |mod|
execute 'module-installation' do
   cwd "#{node['hc_apache']['src_path']}/#{node['hc_apache']['package_name']}/modules/#{mod}"
   command "/usr/local/apache2/bin/apxs -c mod_#{mod}.c -a"
   not_if { ::File.exists?("/usr/local/apache2/modules/mod_#{mod}.so") }
 end
end

service "apache2" do
    action [ :enable, :restart ]
end

execute 'set-PATH' do
  cwd "#{node['hc_apache']['src_path']}/#{node['hc_apache']['package_name']}"
  command "echo -e '# #{node['hc_apache']['home']}  environment settings\n#Auto-generated by Chef Cookbook for apache2\nexport PATH=$PATH:#{node['hc_apache']['home']}/bin' >> ~/.bash_profile"
not_if "grep -w apache2  ~/.bash_profile"
end

#execute 'refresh-properties' do
#  cwd "/tmp"
#  command "source ~/.bash_profile"
#end

bash 'refresh-properties' do
  cwd '/tmp'
  code <<-EOH
    source ~/.bash_profile
    EOH
end

