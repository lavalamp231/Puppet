
node 'default' {
	include ntp_file_replace
}


node 'puppet01.esxi.com' {

	include puppet_agent
	include ntp_file_replace
    include samba::puppet01
    include nfs_client
    include packages_install
    include selinux_disable

    class { 'puppetdb::master::config':
	  puppetdb_server => 'puppetdb.esxi.com',
      puppetdb_port   => 8081,
	}




}

node 'puppetdb' {
	
	include puppet_agent
	include ntp_file_replace
	include nfs_client
	include packages_install
	include selinux_disable

	class { 'puppetdb':
	listen_address => '0.0.0.0',
	open_listen_port => true,
	manage_firewall => false,
	#cacert => "/etc/puppetlabs/puppet/ssl/certs/ca.pem",
    #cert => "/etc/puppetlabs/puppet/ssl/certs/puppetdb.esxi.com.pem",
    #key => "/etc/puppetlabs/puppet/ssl/private_keys/puppetdb.esxi.com.pem.pem"
	certificate_whitelist => [ $::servername ],
	}

	

}

node 'zabbix.esxi.com' {

include puppet_agent
include ntp_file_replace
include nfs_client
include packages_install
include selinux_disable


	
class { 'apache':
    mpm_module => 'prefork',
  }
  include apache::mod::php

  class { 'postgresql::server': }

  class { 'zabbix':
    zabbix_url    => 'zabbix.esxi.com',
  }

 # zabbix::template { 'Template App Disk Performance':
 # templ_source => 'puppet:///modules/zabbix/zabbix-disk-performance/zabbix-disk-performance-master/Template_Disk_Performance.xml',
#}

}

