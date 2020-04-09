jasper Cookbook
==================

This cookbook installs Jasper 5.6 for HIX and WIG products.This has only been tested on RHEL 6. This is a basic cookbook intended as a starting point for your environment.By default this cookbook will install Jasper  into /opt and setup the init script and log directoy. See the usage section for more details.

This cookbook supports below company products

Jasper HIX(hix_jasper.rb) :- /usr/local/jasperreports-server-5.6 /etc/init.d/jasper  
Jasper WIG(wig_jasper.rb) :- /home/jasper/jasperreports-server-5.6 /etc/init.d/jasper  


Requirements
------------
- `jasperreports-server-5.6-linux-x64-installer.run.tar.gz` - Download the zip package from company repo and host on your own server.
- `jasperserver.license.tar.gz` - Download the zip package from company repo and host on your own server.


Attributes
---------
-
The attribute set as :-

#Jasper Service attributes
default['hc_jasper']['hix']['jasper_version'] = '5.6'
default['hc_jasper']['hix']['jasper_license_tar'] = 'jasperserver.license.tar.gz'
default['hc_jasper']['hix']['jasper_tar_name'] = "jasperreports-server-#{node['hc_jasper']['hix']['jasper_version']}-linux-x64-installer.run.tar.gz"
default['hc_jasper']['hix']['jasper_url'] = "artifactory.demo.company.com/artifactory/chef-repo/jasper/hix/#{node['hc_jasper']['hix']['jasper_tar_name']}"
default['hc_jasper']['hix']['license_url'] = "artifactory.demo.company.com/artifactory/chef-repo/jasper/hix/#{node['hc_jasper']['hix']['jasper_license_tar']}"
default['hc_jasper']['hix']['jasper_setup'] = "jasperreports-server-#{node['hc_jasper']['hix']['jasper_version']}-linux-x64-installer.run"
default['hc_jasper']['hix']['jasper_license'] = 'jasperserver.license'
default['hc_jasper']['hix']['jasper_home'] = '/usr/local'
default['hc_jasper']['hix']['jasper_path'] = "/usr/local/jasperreports-server-#{node['hc_jasper']['hix']['jasper_version']}"
default['hc_jasper']['hix']['jasper_package_path'] = '/usr/local/JASPER_PACKAGES'
default['hc_jasper']['hix']['jasper_array'] = ["#{node['hc_jasper']['hix']['jasper_license_tar']}", "#{node['hc_jasper']['hix']['jasper_tar_name']}", "#{node['hc_jasper']['hix']['jasper_setup']}"]
default['hc_jasper']['hix']['user'] = 'jasper'
default['hc_jasper']['hix']['group'] = 'jasper'
default['hc_jasper']['hix']['jasper_temp_dir'] = '/usr/local/jasper_temp'

default['hc_jasper']['wig']['jasper_version'] = '5.6'
default['hc_jasper']['wig']['jasper_license_tar'] = 'jasperserver.license.tar.gz'
default['hc_jasper']['wig']['jasper_tar_name'] = "jasperreports-server-#{node['hc_jasper']['wig']['jasper_version']}-linux-x64-installer.run.tar.gz"
default['hc_jasper']['wig']['jasper_url'] = "artifactory.demo.company.com/artifactory/chef-repo/jasper/hix/#{node['hc_jasper']['wig']['jasper_tar_name']}"
default['hc_jasper']['wig']['license_url'] = "artifactory.demo.company.com/artifactory/chef-repo/jasper/hix/#{node['hc_jasper']['wig']['jasper_license_tar']}"
default['hc_jasper']['wig']['jasper_setup'] = "jasperreports-server-#{node['hc_jasper']['wig']['jasper_version']}-linux-x64-installer.run"
default['hc_jasper']['wig']['jasper_license'] = 'jasperserver.license'
default['hc_jasper']['wig']['jasper_home'] = '/usr/local'
default['hc_jasper']['wig']['jasper_path'] = "/usr/local/jasperreports-server-#{node['hc_jasper']['wig']['jasper_version']}"
default['hc_jasper']['wig']['jasper_package_path'] = '/usr/local/JASPER_PACKAGES'
default['hc_jasper']['wig']['jasper_array'] = ["#{node['hc_jasper']['wig']['jasper_license_tar']}", "#{node['hc_jasper']['wig']['jasper_tar_name']}", "#{node['hc_jasper']['wig']['jasper_setup']}"]
default['hc_jasper']['wig']['jasper_jars'] = ['postgresql-9.1-901-1.jdbc4.jar', 'spring-jdbc-3.1.4.RELEASE.jar', 'custom-wig.jar', 'wig-report.jar', 'gson-2.3.jar' ]
default['hc_jasper']['wig']['jar_url'] = 'artifactory.demo.company.com/artifactory/chef-repo/jasper/wig/jars'
default['hc_jasper']['wig']['zip_name'] = 'jasper_server_export_1.zip'
default['hc_jasper']['wig']['jar_path'] = "#{node['hc_jasper']['wig']['jasper_path']}/apache-tomcat/webapps/jasperserver-pro/WEB-INF/lib"
default['hc_jasper']['wig']['port'] = '5432'
default['hc_jasper']['wig']['db_name'] = 'wigdb_qa'
default['hc_jasper']['wig']['tomcat_server_xml_path'] = "#{node['hc_jasper']['wig']['jasper_path']}/apache-tomcat/conf"
default['hc_jasper']['wig']['jasper_tomcat_http_port'] = '8080'
default['hc_jasper']['wig']['proxy_name'] = 'host_server'
default['hc_jasper']['wig']['proxy_port'] = '8443'
default['hc_jasper']['wig']['show_stack_trace_message'] = 'false'
default['hc_jasper']['wig']['allowscriptaccess'] = 'sameDomain'
default['hc_jasper']['wig']['security_validation'] = 'AlphaNumPunctuation'

default['hc_jasper']['wig']['user'] = 'jasper'
default['hc_jasper']['wig']['group'] = 'jasper'



Usage
-----
#### hc_jasper:hix_jasper
The default recipe downloads the package and unpacks it to the versioned directory (/usr/local/jasper_temp).  The jasper supplied init script is copied to /etc/init.d/jasper.

TODO: Convert this to an array of users

License and Authors
-------------------
Authors: company

