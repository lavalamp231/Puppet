$my_packages = ['vim', 'epel-release', 'deltarpm', 'bash-completion', 'mlocate', 'nmap', 'tcpdump', 'nethogs', 'iotop', 'sysstat', 'wget', 'git', 'yum-utils', 'bind-utils', 'net-tools', 'yum-cron']
$remove_these_bitches = ['nagios-plugins', 'nagios-common']

class packages_install {

	package { $my_packages:
		ensure => installed,
	}

	package { $remove_these_bitches:
		ensure => purged,
	}

	
}

