default['hc_zookeeper']['install']['tmp'] = '/opt/zkp_tmp'
default['hc_zookeeper']['dirs'] = ['/opt/zookeeper-data', '/opt/zkp_tmp', 'var/log/zookeeper']
default['hc_zookeeper']['version'] = '3.4.6'
default['hc_zookeeper']['install_path'] = '/opt'
default['hc_zookeeper']['package']['name'] = "zookeeper-#{node['hc_zookeeper']['version']}.tar.gz"
default['hc_zookeeper']['package']['url']  = "artifactory.demo.company.com/artifactory/chef-repo/zookeeper//#{node['hc_zookeeper']['package']['name']}"
default['hc_zookeeper']['user'] = 'zookeeper'
default['hc_zookeeper']['group'] = 'zookeeper'
default[:hc_zookeeper][:java_opts]   = '-Xms128M -Xmx512M'
default[:hc_zookeeper][:conf_file]   = 'zoo.cfg'
default[:hc_zookeeper][:log_dir]     = '/var/log/zookeeper'
default[:hc_zookeeper][:config] = {
  clientPort: 2181,
  dataDir: '/opt/zookeeper-data',
  logDir: '/var/log/zookeeper',
  tickTime: 5000
}