def directory_exists?(directory)
  Dir.exists?(directory)
end
#is_tomcat_installed = directory_exists("#{node['hc_tomcat']['tomcat_dir_name']}")

if Dir.exist?("#{node['hc_tomcat']['tomcat_dir_name']}")
Chef::Log.info "hc_tomcat::default is_tomcat_installed "
#reg = "| grep 'Server version:' | cut -d: -f2 | cut -d/ -f2"
get_version = "#{node['hc_tomcat']['tomcat_dir_name']}/bin/version.sh | grep 'Server version:' | cut -d: -f2 | cut -d/ -f2"
version  = Mixlib::ShellOut.new(get_version)
version_out = version.run_command.stdout
Chef::Log.info "hc_tomcat::default command out us  #{version_out}"
else
get_version = "#{node['hc_tomcat']['tomcat_dir_name']}/bin/version.sh | grep 'Server version:' | cut -d: -f2 | cut -d/ -f2"
version  = Mixlib::ShellOut.new(get_version)
version_out = version.run_command.stdout
Chef::Log.info "hc_tomcat::default command out us  #{version_out}"




Chef::Log.info "hc_tomcat::default else block"


end
#get_version_cmd = ./version.sh  | grep 'Server version:' | cut -d: -f2 | cut -d/ -f2

