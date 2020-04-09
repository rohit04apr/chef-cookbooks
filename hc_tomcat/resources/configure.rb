#resource_name :tomcat_install
property :template_source, String
property :instance_name, String, name_property: true
property :version, String
property :install_path, String, default: '/usr/local'
#property :tarball_base_path, String, default: 'http://archive.apache.org/dist/tomcat/'
#property :checksum_base_path, String, default: 'http://archive.apache.org/dist/tomcat/'
#property :sha1_base_path, String # this is the legacy name for this attribute
property :exclude_docs, kind_of: [TrueClass, FalseClass], default: true
property :exclude_examples, kind_of: [TrueClass, FalseClass], default: true
property :exclude_manager, kind_of: [TrueClass, FalseClass], default: false
property :exclude_hostmanager, kind_of: [TrueClass, FalseClass], default: false

action_class do

  # break apart the version string to find the major version
  #not using
  def major_version
    @major_version ||= new_resource.version.split('.')[0]
  end

  # the install path of this instance of tomcat
  #not using
  def full_install_path
    if new_resource.install_path
      new_resource.install_path
    else
      @path ||= "#{new_resource.install_path}/#{new_resource.instance_name}/"
    end
  end

  # build the extraction command based on the passed properties
  def extraction_command
    #cmd = "tar -xzf #{Chef::Config['file_cache_path']}/apache-tomcat-#{new_resource.version}.tar.gz -C #{full_install_path} --strip-components=1"
    cmd = "tar xzvf #{node['hc_tomcat']['package_name']} -C #{node['hc_tomcat']['install_path']}"
    cmd << " --exclude='*webapps/examples*'" if new_resource.exclude_examples
    cmd << " --exclude='*webapps/ROOT*'" if new_resource.exclude_examples
    cmd << " --exclude='*webapps/docs*'" if new_resource.exclude_docs
    cmd << " --exclude='*webapps/manager*'" if new_resource.exclude_manager
    cmd << " --exclude='*webapps/host-manager*'" if new_resource.exclude_hostmanager
    cmd
  end

end

action :install do

log 'Starting Tomcat LWRP' do
  message 'Starting Tomcat LWRP'
  level :info
end
  # some RHEL systems lack tar in their minimal install
  package 'tar'
  # Grab and unpack tomcat package
  artfct_user_details = data_bag_item('chef_credentials', node['chef_credentials']['artifactory'])
  remote_file "/opt/#{node['hc_tomcat']['package_name']}" do
    source "http://#{artfct_user_details['username']}:#{artfct_user_details['password']}@artifactory.demo.company.com/artifactory/chef-repo/tomcat/#{node['hc_tomcat']['package_name']}"
    owner 'root'
    group 'root'
    mode '0755'
  end
  
  execute 'extract_tomcat_tar' do
    command "tar xzvf #{node['hc_tomcat']['package_name']} -C #{node['hc_tomcat']['install_path']}"
    cwd '/opt'
    not_if { ::Dir.exists?("#{node['hc_tomcat']['install_path']}/#{node['hc_tomcat']['tomcat_dir_name']}") }
  end
  
  execute 'extract tomcat tarball' do
    cwd '/opt'
    command extraction_command
    action :run
  end
  
  execute "chown-tomcat" do
    cwd node['hc_tomcat']['install_path']
    command  "chown -R #{node['hc_tomcat']['user']}:#{node['hc_tomcat']['group']} #{node['hc_tomcat']['tomcat_dir_name']}"
    
  end
  
  #node['hc_tomcat']['remove_dirs'].each do |dir_name|
  #  directory "#{node['hc_tomcat']['tomcat_home']}/webapps/#{dir_name}" do
  #    action :delete
  #    recursive true
  #  end
  #end
  
 #template "#{node['hc_tomcat']['tomcat_home']}/bin/setenv.sh" do
 #   source "product/#{new_resource.template_source}/setenv.sh.erb"
 #   mode '0644'
 #   owner node['hc_tomcat']['user']
 #   group node['hc_tomcat']['group']
 # end
  

  [node['hc_tomcat']['log_dir'], node['hc_tomcat']['scimweblogs_dir']].each do |dir|
     directory  dir do
       mode '2775'
       recursive true
       user 'tomcat'
       group 'tomcat'
     end
   end

  # Even for the base instance, the OS package may not make this directory
  directory "#{node['hc_tomcat']['lib_dir']}/endorsed" do
    mode '0755'
    user 'tomcat'
    group 'tomcat'
    recursive true
  end
  
end