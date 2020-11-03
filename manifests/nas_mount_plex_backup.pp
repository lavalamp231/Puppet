# Class: nas_mount_plex_backup
#
#
class nas_mount_plex_backup {
	
	file { '/Plex_Backup':
		ensure => directory,
	}
	
	mount { 'nas_plex_backup':
        device => '192.168.0.3:/volume2/Plex_Backup',
        name => '/Plex_backup',
        require => File[/Misc],
        options => '_netdev,nfsvers=3',
    	ensure => mounted,
    	fstype => "nfs",
		}
}