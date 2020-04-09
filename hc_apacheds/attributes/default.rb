default['hc_apacheds']['version'] = '2.0.0-M19'
if node['hc_apacheds']['version'] == '2.0.0-M19'
  default['hc_apacheds']['package']['url'] = 'artifactory.demo.company.com/artifactory/chef-repo/apacheds/apacheds-2.0.0-M19.tar.gz'
  default['hc_apacheds']['package']['name'] = 'apacheds-2.0.0-M19.tar.gz'
end
default['hc_apacheds']['chef']['databag']['name'] = 'chef_credentials'
default['hc_apacheds']['chef']['databag']['id'] = 'artifactory'
default['hc_apacheds']['install']['path'] = '/opt/idm'
default['hc_apacheds']['install']['tmp'] = '/opt/apacheds_temp'
default['hc_users']['other_users'] = ['idm']
default['hc_apacheds']['user'] = 'idm'
default['hc_apacheds']['group'] = 'idm'
default['hc_apacheds']['config'] = ['/opt/idm/resources', '/home/idm/.m2']
default['hc_apacheds']['pwdpolicy_prop'] = 'pwdPolicy.properties'
default['hc_apacheds']['xmx_percentage'] = '40'
if node['hc_apacheds']['xmx'] == nil
  default['hc_apacheds']['xmx'] = (node['memory']['total'][0..-3].to_f / 1024) * (node['hc_apacheds']['xmx_percentage'].to_f / 100)
end
default['hc_apacheds']['java_options'] = "-Xms#{node['hc_apacheds']['xmx'].to_i}M -Xmx#{node['hc_apacheds']['xmx'].to_i}M -Dconfig=#{node['hc_apacheds']['install']['path']}/resources/pwdPolicy.properties"
default['hc_users']['execute']['timeout'] = 300
