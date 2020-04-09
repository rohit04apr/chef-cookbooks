name             'hc_sudo'
maintainer       'company'
maintainer_email 'rohit.tiwari@company.com'
license          'All rights reserved'
description      'Installs/Configures hc_sudo'
long_description 'Installs/Configures hc_sudo'
version          '0.1.1'

depends 'sudo', '=2.7.2'

%w(redhat centos fedora ubuntu debian freebsd mac_os_x).each do |os|
  supports os
end

