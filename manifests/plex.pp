# Class: exercise1::plex
#
#
class exercise1::plex {
	
	file { '/tmp/plex.rpm':
		ensure => file,
		source => 'https://downloads.plex.tv/plex-media-server-new/1.19.1.2645-ccb6eb67e/redhat/plexmediaserver-1.19.1.2645-ccb6eb67e.x86_64.rpm',
	}

	package { 'plexmediaserver-1.19.1.2645-ccb6eb67e.x86_64':
		ensure => installed,
		provider => rpm,
		require => File['/tmp/plex.rpm'],
		install_options => '-Uvh',
		source => '/tmp/plex.rpm',
	}

}