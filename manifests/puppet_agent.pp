$puppet_content = @(END)

[main]
server = puppet01.esxi.com
environment = production
runinterval = 3600

END



class puppet_agent {
	
	service { 'puppet':
		enable      => true,
		ensure      => running,
		#hasrestart => true,
		#hasstatus  => true,
		#require    => Class["config"],
	}

	file { '/etc/puppetlabs/puppet.conf':
		ensure => file,
		content => $puppet_content,
		force => true,
	}
}