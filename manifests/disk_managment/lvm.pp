class exercise1::disk_managment::lvm {

	require exercise1::disk_managment::disk
	require exercise1::users::users

	physical_volume { '/dev/sdb1':
	  ensure => present,
	}

	physical_volume { '/dev/sdc1':
	  ensure => present,
	}

	volume_group { 'exercisevg':
	  ensure           => present,
	  physical_volumes => ['/dev/sdb1', '/dev/sdc1'],
	}

	logical_volume { 'exercise.fs':
	  ensure       => present,
	  volume_group => 'exercisevg',
	  size         => '12G',
	}

	filesystem { '/dev/exercisevg/exercise.fs':
	  ensure  => present,
	  fs_type => 'xfs',
	}


	$mydir = hiera('exercise1::directory', {})
	create_resources(file, $mydir)

	mount { '/exercise':
		ensure => mounted,
		pass   => 0,
		dump   => 0,
		fstype => 'xfs',
		options => 'defaults',
		device => '/dev/exercisevg/exercise.fs',
		require => Filesystem['/dev/exercisevg/exercise.fs']
	}
}