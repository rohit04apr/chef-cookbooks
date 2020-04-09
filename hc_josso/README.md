hc_josso Cookbook
==================

This cookbook installs JOSSO EE and CE. This has only been tested on RHEL 6.  This is a basic cookbook intended as a starting point for your environment. This cookbook will install JOSSO EE and CE into /opt/idm/<josso-ce>,<josso-ee> and setup the init script and log directoy. See the usage section for more details.The user and group "idm" will be created as well.

**Special attention should be paid to the permissions set on the JOSSO files as this cookbook sets them all to be writable by the jboss user and should not be considered a secure setup.**

### Dependency
* hc_users
* hc_sudo

### Requirements

### Attributes
----------
- `default['hc_josso']['josso_envsetup']['download_link'] = "artifactory.demo.company.com/artifactory/chef-repo"`
- `default['hc_josso']['josso_envsetup']['source_download_path'] = "#{node['hc_josso']['josso_envsetup']['download_link']}/josso-ee-2.4.2-unix.jar"`
- `default['hc_josso']['josso_envsetup']['license_download_path'] = "#{node['hc_josso']['josso_envsetup']['download_link']}/atricore.lic"`
- `default['hc_josso']['josso_envsetup']['install_file_path'] ="#{node['hc_josso']['josso_envsetup']['download_link']}/install.xml"`
- `default['hc_josso']['josso_path'] = "/opt/idm/josso-ee"`
- `default['hc_josso']['josso_ce_path'] = "/opt/idm/josso-ce"`
- `default['hc_josso']['josso_envsetup']['dest_copy_path'] = node['hc_josso']['josso_path']`
- `default['hc_josso']['josso_envsetup']['dest_copy_ce_path'] = node['hc_josso']['josso_ce_path']`
- `default['hc_josso']['josso_envsetup']['untar_loc'] = "#{node['hc_josso']['josso_path']}/temp"`
- `default['hc_josso']['josso_ee_license_path'] = "#{node['hc_josso']['josso_path']}/atricore.lic"`
- `default['hc_josso']['josso_installfile_path'] = "#{node['hc_josso']['josso_path']}/install.xml"`
- `#default['hc_josso']['ee']['installfile_path'] = "#{node['hc_josso']['josso_path']}/install.xml"`
- `default['hc_josso']['ce']['jar_name'] = 'josso-ce-2.4.0-unix.jar'`
- `default['hc_josso']['ce']['tar_name'] = 'josso-ce-2.4.0-unix.jar.tar.gz'`
- `default['hc_josso']['ce']['url'] = "artifactory.demo.company.com/artifactory/chef-repo/josso/#{node['hc_josso']['ce']['tar_name']}"`
- `default['hc_josso']['ce']['dir_path'] = node['hc_josso']['josso_ce_path']`
- `default['hc_josso']['ce']['clean_files'] = ['josso-ce-2.4.0-unix.jar', 'install']`
- `default['hc_josso']['ce']['josso_home'] = '/opt/idm/josso-ce'`
- `default['hc_users']['users'] = ['idm']`



Usage
-----
To install Josso CE, add hc_josso::ce recipe at node runlist. Similarily add hc_josso::ee recipe at node runlist to install Jboss CE. You may also may override the default attribute values mentioned in attributes section.


License and Authors
-------------------
Authors: company

