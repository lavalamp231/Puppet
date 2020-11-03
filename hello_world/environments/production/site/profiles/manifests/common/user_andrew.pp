# Class: user_andrew
#
#
class profiles::common::user_andrew {

        group { 'sambagroup':
                ensure => 'present',
                gid    => lookup('users::gid'),
}

~>

        user { lookup('users::Andrew'):
          ensure  => present,
          comment => 'NFS and Samba user',
          home    => '/home/Andrew',
          shell  => '/bin/bash',
          uid    => lookup('users::uid'),
          gid    => lookup('users::gid'), 
        }

}
