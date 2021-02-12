# Class: exercise1::sudoers
#
#
class exercise1::sudoers {
	$sudoers = hiera('exercise1::sudoers', {})
	create_resources(file, $sudoers)
}