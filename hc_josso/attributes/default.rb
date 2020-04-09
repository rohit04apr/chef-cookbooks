default['hc_josso']['josso_envsetup']['download_link'] = "artifactory.demo.company.com/artifactory/chef-repo/josso"
default['hc_josso']['josso_envsetup']['source_download_path'] = "#{node['hc_josso']['josso_envsetup']['download_link']}/josso-ee-2.4.2-unix.jar"
default['hc_josso']['josso_envsetup']['license_download_path'] = "#{node['hc_josso']['josso_envsetup']['download_link']}/atricore.lic"
default['hc_josso']['josso_envsetup']['install_file_path'] = "#{node['hc_josso']['josso_envsetup']['download_link']}/install.xml"

default['hc_josso']['josso_path'] = "/opt/idm/josso-ee"
default['hc_josso']['ce']['josso_ce_path'] = "/opt/idm/josso-ce"

default['hc_josso']['josso_envsetup']['dest_copy_path'] = node['hc_josso']['josso_path']
default['hc_josso']['josso_envsetup']['dest_copy_ce_path'] = node['hc_josso']['ce']['josso_ce_path']
default['hc_josso']['josso_envsetup']['untar_loc'] = "#{node['hc_josso']['josso_path']}/temp"

default['hc_josso']['josso_ee_license_path'] = "#{node['hc_josso']['josso_path']}/etc/atricore.lic"
default['hc_josso']['josso_installfile_path'] = "#{node['hc_josso']['josso_path']}/install.xml"
#default['hc_josso']['ee']['installfile_path'] = "#{node['hc_josso']['josso_path']}/install.xml"
default['hc_josso']['ce']['jar_name'] = 'josso-ce-2.4.0-unix.jar'
default['hc_josso']['ce']['tar_name'] = 'josso-ce-2.4.0-unix.jar.tar.gz'
default['hc_josso']['ce']['url'] = "artifactory.demo.company.com/artifactory/chef-repo/josso/#{node['hc_josso']['ce']['tar_name']}"
default['hc_josso']['ce']['dir_path'] = '/opt/idm'
default['hc_josso']['ce']['clean_files'] = ["#{node['hc_josso']['ce']['jar_name']}" , 'install']
default['hc_josso']['ce']['josso_home'] = '/opt/idm/josso-ce'
default['hc_josso']['ce']['dirs'] = ['/opt/idm', '/opt/idm/josso-ce', '/opt/idm/resources','/home/idm/.m2']

default['hc_josso']['ee']['dir_path'] = '/opt/idm'
default['hc_josso']['ee']['jar_name'] = 'josso-ee-2.4.2-unix.jar'
default['hc_josso']['ee']['tar_name'] = 'josso-ee-2.4.2-unix.jar.tar.gz'
default['hc_josso']['ee']['url'] = "artifactory.demo.company.com/artifactory/chef-repo/josso/#{node['hc_josso']['ee']['tar_name']}"
default['hc_josso']['ee']['clean_files'] = ["#{node['hc_josso']['ee']['jar_name']}" , 'install' ]
#default['hc_josso']['ee']['dirs'] = ['/opt/idm/josso-ee','/home/idm/.m2']
default['hc_josso']['ee']['dirs'] = ['/opt/idm', '/opt/idm/josso-ee', '/opt/idm/resources','/home/idm/.m2']
default['hc_josso']['ee']['josso_ee_path'] = "/opt/idm/josso-ee"

#Josso EE Specific properties
default['hc_josso']['ee']['opts']['xmx_percentage'] = '60'
default['hc_josso']['ee']['opts']['xms'] = '2048m'
#default['hc_josso']['ee']['opts']['xmx'] = '2048m'
default['hc_josso']['ee']['opts']['maxpermsize'] = '512m'

if node[:hc_josso][:ee][:opts].attribute?(:xmx)
  default['hc_josso']['ee']['opts']['xms'] = node['hc_josso']['ee']['opts']['xmx']
else     
  default['hc_josso']['ee']['opts']['xmx'] = (node['memory']['total'][0..-3].to_f / 1024) * (node['hc_josso']['ee']['opts']['xmx_percentage'].to_f / 100)
  default['hc_josso']['ee']['opts']['xmx'] = "#{node['hc_josso']['ee']['opts']['xmx'].to_i}M"
  default['hc_josso']['ee']['opts']['xms'] = node['hc_josso']['ee']['opts']['xmx']
end
