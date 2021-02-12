# Class: exercise1::time
#
#
class exercise1::time {
	class { 'timezone':
    timezone => 'AMERICAS/Chicago',
	}

}