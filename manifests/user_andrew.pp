# Class: user_andrew
#
#
class user_andrew {
	
	group { 'sambagroup':
  		ensure => 'present',
  		gid    => '1080',
}

~>

	user { 'Andrew':
	  ensure  => present,
	  comment => 'NFS and Samba user',
	  home    => '/home/Andrew',
	  shell  => '/bin/bash',
	  uid    => '1000',
	  gid    => '1080'
	}

}