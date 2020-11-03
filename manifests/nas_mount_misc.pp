#### Variables #####

$mount_options = {
	options => '_netdev,nfsvers=3',
    ensure => mounted,
    fstype => "nfs",
}


####################



# Class: nas_mount
#
#
class nas_mount_misc {

	file { '/Misc':
		ensure => directory,
	}
	
	mount { 'nas_plex_backup':
        device => '192.168.0.3:/volume1/Misc',
        name => '/Misc',
        require => File[/Misc],
        *	=> $mount_options,
		}

}