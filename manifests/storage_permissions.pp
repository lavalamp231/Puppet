$nfs_directories = ['/Storage2', '/Storage', '/Backup']

# Class: storage_permissions
#
#
class storage_permissions {
	file { $nfs_directories:
		ensure => directory,
		recurse => false,
		owner => 'Andrew',
		group => 'sambagroup',
	}
}