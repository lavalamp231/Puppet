#### Variables #####

$storage_directories = ['/Storage', '/Backup', '/Code']
$nas_code = ['/Code']
$nas_misc = ['/Misc']
$plex_backup = ['/Plex_backup']


$mount_options = {
	options => '_netdev,nfsvers=3',
    ensure => mounted,
    fstype => "nfs",
}


####################


class nfs_client {

	file { [$nas_misc, $plex_backup]:
		ensure => directory,
	}


# Using case 	

case $facts['hostname'] {

	'plex', 'storage': {
		
		mount { 'nas_plex_backup':
        device => '192.168.0.3:/volume2/Plex_Backup',
        name => '/Plex_backup',
        require => File[$plex_backup],
        *	=> $mount_options,
        
		}
					
} # closing the plex, storage "case"

# Setting up the /Misc mount as default

default: {
	
	mount { 'nas_misc':
        device => '192.168.0.3:/volume1/Misc',
        name => '/Misc',
        require => File[$nas_misc],
        * => $mount_options,
	}
	
} # closing default "case"

}

} # Cloing the class