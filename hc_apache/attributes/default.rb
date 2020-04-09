#
# Cookbook Name:: hc_apache
# 
# Copyright (C) 2015 company
#
# All rights reserved - Do Not Redistribute
#

## company attributes
default['hc_apache']['servername'] = 'localhost'

## NOTE: The CIST apache hardening guide recommends disabling proxy modules.
## But company uses apache almost entirely as a proxy server.
## Thus, enabling proxy modules.
# Default modules to load
default['hc_apache']['modules'] = %w(
  alias filter headers include log_config mime rewrite authz_core authz_host authz_user
    authz_groupfile authn_file autoindex deflate dir env logio negotiation status
  proxy proxy_http setenvif
)

default['hc_apache']['mod'] = %w(ssl proxy)

default['hc_apache']['version'] = "2.4"
default['hc_apache']['sub_version'] = "18"
default['hc_apache']['src_path'] = '/usr/src'
default['hc_apache']['init_path'] = '/etc/init.d/apache2'
default['hc_apache']['home'] = '/etc/apache2'

if node['hc_apache']['version'] == '2.4' && node['hc_apache']['sub_version'] == '18'
    default['hc_apache']['package_name']='httpd-2.4.18'
    default['hc_apache']['apr_package_name']='apr-1.5.2'
    default['hc_apache']['apr_util_package_name']='apr-util-1.5.4'
    default['hc_apache']['pcre_name']='pcre-8.37'
    default['hc_apache']['url'] = 'artifactory.demo.company.com/artifactory/chef-repo/apache/httpd-2.4.18.tar.bz2'
    default['hc_apache']['apr_url'] = 'artifactory.demo.company.com/artifactory/chef-repo/apache/apr-1.5.2.tar.gz'
    default['hc_apache']['apr_util_url'] = 'artifactory.demo.company.com/artifactory/chef-repo/apache/apr-util-1.5.4.tar.gz'
    default['hc_apache']['pcre_url'] = 'artifactory.demo.company.com/artifactory/chef-repo/apache/pcre-8.37.tar.gz'
    default['hc_apache']['allmodules'] = '--with-mpm=prefork'
end

# RHEl 6.x Apache 2.4 fix
if node['hc_apache']['version'] == "2.4"
override['apache']['version'] =  node['hc_apache']['version']
if node['platform_family'] == "rhel"
	if node['platform_version'] =~ /6.*/
                default['apache']['listen']['*'] = ['80']
		default['apache']['package'] = 'httpd24'
		default['apache']['devel_package'] = 'httpd24-devel'
		default['apache']['service_name'] = 'httpd24-httpd'
		default['apache']['apachectl']   = '/opt/rh/httpd24/root/usr/sbin/apachectl'
		default['apache']['dir']         = '/opt/rh/httpd24/root/etc/httpd'
		default['apache']['log_dir']     = '/opt/rh/httpd24/root/var/log/httpd'
		default['apache']['binary']      = '/opt/rh/httpd24/root/usr/sbin/httpd'
		default['apache']['conf_dir']    = '/opt/rh/httpd24/root/etc/httpd/conf'
		default['apache']['docroot_dir'] = '/opt/rh/httpd24/root/var/www/html'
		default['apache']['cgibin_dir']  = '/opt/rh/httpd24/root/var/www/cgi-bin'
		default['apache']['icondir'] = '/opt/rh/httpd24/root/usr/share/httpd/icons'
		default['apache']['cache_dir']   = '/opt/rh/httpd24/root/var/cache/httpd'
		default['apache']['run_dir']     = '/opt/rh/httpd24/root/var/run/httpd'
		default['apache']['lock_dir']    = '/opt/rh/httpd24/root/var/run/httpd'
		default['apache']['pid_file']   = '/opt/rh/httpd24/root/var/run/httpd/httpd.pid'
		default['apache']['lib_dir'] = '/opt/rh/httpd24/root/usr/lib64/httpd'
		default['apache']['libexec_dir'] = "#{node['apache']['lib_dir']}/modules"
		default['hc_apache']['modules'] = %w(
  alias filter headers include log_config mime rewrite autoindex deflate dir env logio negotiation status
  proxy proxy_http setenvif authz_core unixd access_compat cache authz_host 
)
end
	end
end
default['apache']['listen']['*'] = ['80']
default['hc_apache']['apache2.4']['repo'] = "artifactory.demo.company.com/artifactory/chef-repo/repos/epel-httpd24.repo"

# extra modules to load
# these should be overridden in application cookbooks if extra modules are required.
default['hc_apache']['extra_modules'] = %w()

# default modules
#default['apache']['default_modules'] = default['hc_apache']['modules'].concat(default['hc_apache']['extra_modules'])
default['apache']['default_modules'] = node['hc_apache']['modules'].concat(node['hc_apache']['extra_modules'])

# Virtual host entries
default['hc_apache']['virtualhost']['basepath'] = '/usr/local/phix'
default['hc_apache']['virtualhost']['portals'] = ['employee', 'admim']
default['hc_apache']['arshop_hix']['virtualhost']['portals'] = ['csr', 'pms', 'pmsadmin', 'employer', 'employee']
default['hc_apache']['virtualhost']['loglevel'] = 'info'
default['hc_apache']['virtualhost']['backend']['protocal']  = 'ajp'
default['hc_apache']['virtualhost']['backend']['ip'] = 'localhost'
default['hc_apache']['virtualhost']['backend']['port'] = '8009'
default['hc_apache']['virtualhost']['errordocument'] = [
{
	'code' => '400',
	'file' => '/staticContent/apache/error.html'
},
{
	'code' => '401',
	'file' => '/staticContent/apache/forbidden.html'
},
{
	'code' => '403',
	'file' => '/staticContent/apache/forbidden.html'
}]
default['hc_apache']['virtualhost']['content_security_policy'] = '"default-src \'self\' *.google-analytics.com *.livelook.com *.livelook.net *.ssl.cf2.rackcdn.com  *.googleapis.com *.youtube.com *.gstatic.com maps.google.com/mapfiles/ms/icons/blue-dot.png *.liveperson.net *.lpsnmedia.net va.v.liveperson.net hello.myfonts.net *.livechatinc.com \'unsafe-inline\' \'unsafe-eval\'; img-src \'self\' data: *.google-analytics.com *.ssl.cf2.rackcdn.com *.livelook.net *.livelook.com *.googleapis.com *.youtube.com *.gstatic.com maps.google.com/mapfiles/ms/icons/blue-dot.png"'
default['hc_apache']['virtualhost']['arshop_hix']['content_security_policy'] = '"default-src \'self\' \'unsafe-inline\' \'unsafe-eval\' http://fonts.googleapis.com https://maxcdn.bootstrapcdn.com http://fonts.gstatic.com http://www.google-analytics.com https://maps.googleapis.com https://maps.google.com https://csi.gstatic.com http://ajax.googleapis.com https://ssl.google-analytics.com data:"'
default['hc_apache']['virtualhost']['servername'] = ""
default['hc_apache']['virtualhost']['serveralias'] = ""
#CP_PHIX Specific properties
<<'COMMENT'
default['hc_apache']['phix']['cp']['virtualhost']['servername'] = ''
default['hc_apache']['phix']['cp']['virtualhost']['serveralias'] = ''
default['hc_apache']['phix']['cp']['virtualhost']['content_security_policy'] = '"default-src \'self\' *.google-analytics.com *.livelook.com *.livelook.net *.ssl.cf2.rackcdn.com  *.googleapis.com *.youtube.com *.gstatic.com maps.google.com/mapfiles/ms/icons/blue-dot.png *.liveperson.net *.lpsnmedia.net va.v.liveperson.net hello.myfonts.net *.livechatinc.com \'unsafe-inline\' \'unsafe-eval\'; img-src \'self\' data: *.google-analytics.com *.ssl.cf2.rackcdn.com *.livelook.net *.livelook.com *.googleapis.com *.youtube.com *.gstatic.com maps.google.com/mapfiles/ms/icons/blue-dot.png"'
default['hc_apache']['phix']['cp']['virtualhost']['backend']['protocol'] = ''
default['hc_apache']['phix']['cp']['virtualhost']['backend']['ip'] = ''
default['hc_apache']['phix']['cp']['virtualhost']['backend']['port'] = ''
default['hc_apache']['phix']['cp']['virtualhost']['portals'] = ['']
COMMENT
default['hc_apache']['phix']['cp']['dirs'] = ['/usr/local/phix', '/usr/local/phix/applications']
default['hc_apache']['phix']['cp']['conf']['base_domain'] = 'hcphix.com'
#WFM properties
default['hc_apache']['wfm']['virtualhost']['portal']['api_domain'] = 'api-sit.company.com'
default['hc_apache']['wfm']['virtualhost']['portal']['play_domain'] = 'play-sit.company.com'
default['hc_apache']['wfm']['virtualhost']['portal']['payments_domain'] = 'payments-sit.company.com'
default['hc_apache']['wfm']['virtualhost']['portal']['arkansas_domain'] = 'arshop-sit.company.com'
default['hc_apache']['wfm']['ws']['dirs'] = ['/usr/local/applications/wfm', '/usr/local/applications/wfm/ui/wfm-ui']
##Fidelity attributes
default['hc_apache']['phix']['fidelity']['conf']['base_domain'] = 'fidelity.demo.company.com'
default['hc_apache']['phix']['wellcare']['conf']['base_domain'] = 'wellcare.demo.company.com'
