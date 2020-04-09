#
# Cookbook Name:: hc_josso
# Recipe:: ce
#
# Copyright (c) 2016 company, All Rights Reserved.
#download josso_ee setup


begin
Chef::Log.info 'hc_josso::ce recipe execution started'
 <<'COMMENT'
  #create user and group "idm"
  user 'idm' do
    comment "user create for josso"
    supports :manage_home => true
    system true
    shell "/bin/bash"	
    home "/home/idm"
  end
COMMENT
  #create directories
  
node['hc_josso']['ce']['dirs'].each do |dir|
  directory "#{dir}" do
    owner 'idm'
    group 'idm'
    mode '2775'
    recursive true
    action :create
  end
end

#Give group permission to folder.
directory '/home/idm' do
    owner 'idm'
    group 'idm'
    mode '770'
    recursive true
    action :create
end

  #Get artifactory credentials from databag
  artfct_user_details = data_bag_item('chef_credentials', 'artifactory')

  #Download ce jar from artifactory
  remote_file "#{node['hc_josso']['ce']['josso_ce_path']}/#{node['hc_josso']['ce']['tar_name']}" do
    source "http://#{artfct_user_details['username']}:#{artfct_user_details['password']}@#{node['hc_josso']['ce']['url']}"
    owner 'idm'
    group 'idm'
    mode '0755'
    action :create_if_missing
    notifies :run, "execute[extract josso-ce tar]", :immediately
  end

  execute 'extract josso-ce tar' do
    cwd node['hc_josso']['ce']['josso_ce_path']
    user 'idm'
    group 'idm'
    command "tar xzvf #{node['hc_josso']['ce']['tar_name']} -C #{node['hc_josso']['ce']['josso_ce_path']}"
    action :nothing
    notifies :create, "template[#{node['hc_josso']['ce']['josso_ce_path']}/install]", :immediately
    notifies :run, "execute[install joss-ce]", :immediately
    not_if { ::File.exists?("#{node['hc_josso']['ce']['jar_name']}") }
  end



  template "#{node['hc_josso']['ce']['josso_ce_path']}/install" do
    source 'ce.install.erb'
    mode '0755'
    owner 'idm'
    group 'idm'
    action :nothing
  end

  template "/etc/init.d/josso-ce" do
    source 'ce.service.erb'
    mode '0755'
    owner 'idm'
    group 'idm'
  end

  #josso -ce command execution
  execute 'install joss-ce' do
  cwd node['hc_josso']['ce']['josso_ce_path']
  user 'idm'
  group 'idm'
  command "java -jar #{node['hc_josso']['ce']['jar_name']} install"
  action :nothing
  end

#change permission of josso setup
  execute 'josso_permissions_change' do
  cwd node['hc_josso']['josso_envsetup']['dest_copy_ce_path']
  command "chmod -R 775 *"
  action :run
  end


  service 'josso-ce' do
    action [:enable, :start]
  end


ensure
  #Cleanup downloaded tar
    Chef::Log.info "hc_josso::ce Cleaning up unwanted files......"
    node['hc_josso']['ce']['clean_files'].each do |file|
      file "#{node['hc_josso']['ce']['josso_ce_path']}/#{file}" do
        action :delete
        backup false
      end
    end
Chef::Log.info 'hc_josso::ce recipe execution finished'
end


