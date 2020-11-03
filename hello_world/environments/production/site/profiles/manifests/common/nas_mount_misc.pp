#### Variables #####




####################



# Class: nas_mount
#
#
class profiles::common::nas_mount_misc {

$mount_options = {
	options => '_netdev,nfsvers=3',
    ensure => mounted,
    fstype => "nfs",
}


	file { '/Misc':
		ensure => directory,
	}

  ~>

	mount { 'nas_misc':
        device => '192.168.0.3:/volume1/Misc',
        name   => '/Misc',
	      *      => $mount_options,
  }

}
