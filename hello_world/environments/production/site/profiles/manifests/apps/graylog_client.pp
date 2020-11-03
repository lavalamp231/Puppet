# Class: graylog_client
#
#

service { 'rsyslog':
	enable      => true,
	ensure      => running,
}


class graylog_client {
	file { '/etc/rsyslog.conf':
  ensure => present,
	}

->

file_line { 'Append a line to /etc/rsyslog.conf':
  path => '/etc/rsyslog.conf',  
  line => '*.* @192.168.0.9:5140',
  notify => Service['rsyslog'],
}


}