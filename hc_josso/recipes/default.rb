#
# Cookbook Name:: hc_josso
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.


#create user and group "idm"

user "idm" do 
 comment "user create for josso ee"
 system true
 shell "/bin/bash"
 home "/home/idm"
 end


#create folder strucuture

directory "/opt/idm/josso-ee/" do
  owner 'idm'
    group 'idm'
      mode '0755'
recursive true
action :create
	end


#download josso_ee setup

artfct_user_details = data_bag_item('chef_credentials', 'artifactory')
remote_file "#{node['hc_josso']['josso_envsetup']['dest_copy_path']}/josso-ee-2.4.2-unix.jar" do
 source "http://#{artfct_user_details['username']}:#{artfct_user_details['password']}@#{node['hc_josso']['josso_envsetup']['source_download_path']}"
 owner 'idm'
 group 'idm'
 mode '0755'
 action :create
 end

#download josso_install.xml
artfct_user_details = data_bag_item('chef_credentials', 'artifactory')
remote_file "#{node['hc_josso']['josso_envsetup']['dest_copy_path']}/install.xml" do
 source "http://#{artfct_user_details['username']}:#{artfct_user_details['password']}@#{node['hc_josso']['josso_envsetup']['install_file_path']}"
  owner 'idm'
   group 'idm'
    mode '0755'
     action :create
      end

#download josso_license file
artfct_user_details = data_bag_item('chef_credentials', 'artifactory')
remote_file "#{node['hc_josso']['josso_envsetup']['dest_copy_path']}/atricore.lic" do
 source "http://#{artfct_user_details['username']}:#{artfct_user_details['password']}@#{node['hc_josso']['josso_envsetup']['license_download_path']}"
  owner 'idm'
   group 'idm'
    mode '0755'
     action :create
      end


#start the josso_ee

execute 'josso_startup_comand' do
  cwd node['hc_josso']['josso_envsetup']['dest_copy_path']
user 'idm'
group 'idm'
umask '002'
command 'java -jar josso-ee-2.4.2-unix.jar install.xml'
  end

#change permission of josso setup
execute 'josso_permissions_change' do
cwd node['hc_josso']['josso_envsetup']['dest_copy_ce_path']
command "chmod -R 775 *"
action :run
end

#josso start
execute 'josso ee start' do
cwd "#{node['hc_josso']['josso_envsetup']['dest_copy_ce_path']}/bin"
command "./start"
action :run
end


#josso_sleep


#apply license file
execute 'apply_atricore_license' do
 cwd "#{node['hc_josso']['josso_envsetup']['dest_copy_ce_path']}/bin"

command "./client -u admin -p atricore -h localhost 'licensing:activate -l #{node['hc_josso']['josso_ee_license_path']}'"
 end

