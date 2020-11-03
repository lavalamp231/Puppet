class profiles::common::ntp_file_replace {

unless $facts['hostname'] == 'ntp' {

file {'/etc/ntp.conf':
	ensure => present,
	#source => 'puppet:///modules/ntp_client/ntp.conf',
	replace => true,
	notify => Service['ntpd'],
	content => "\n server 192.168.0.25 iburst \n restrict ${facts['ipaddress']} \n includefile /etc/ntp/crypto/pw  \n keys /etc/ntp/keys \n disable monitor \n driftfile /var/lib/ntp/drift",	
}

}

service {'ntpd':
	ensure => running,
	enable => true,
}

}
