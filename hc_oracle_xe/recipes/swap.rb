bash 'set_swap_space' do
  cwd '/tmp'
  code <<-EOH
	dd if=/dev/zero of=/swapfile bs=1024 count=3000000
	mkswap /swapfile
	swapon /swapfile
	echo '/swapfile               swap                    swap    defaults        0 0' >> /etc/fstab
 EOH
end

