# Class: plex_server
#
#
class profiles::apps::plex_server {
	
	mount { 'storage2':
        fstype => "nfs",
        device => '192.168.0.10:/Storage2',
        options => '_netdev,nfsvers=3',
        ensure => mounted,
       	name => '/Plex',
	}

	service { 'plexmediaserver':
		enable      => true,
		ensure      => running,
	}

	yumrepo { 'plex_repo':
		baseurl    => 'https://downloads.plex.tv/repo/rpm/$basearch/',
		descr      => 'The plex_repo repository',
		enabled    => '1',
		gpgcheck   => '1',
		gpgkey     => 'https://downloads.plex.tv/plex-keys/PlexSign.key',
		#mirrorlist => ''
	}

	~> 
	
	package { 'plexmediaserver':
		ensure => latest,
		notify => Service['plexmediaserver'],
	}

}
