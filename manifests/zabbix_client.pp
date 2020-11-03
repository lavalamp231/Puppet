# Class: zabbix_client
#
#
class zabbix_client {
	
	class { 'zabbix::agent':
  server => '192.168.0.31',
}

}