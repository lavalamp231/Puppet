class exercise1::users::users {
	
	$my_group = hiera('exercise1::groups', {})
	create_resources(group, $my_group)

	# Create a hash from Hiera Data with the Users
	$myUsers = hiera('exercise1::users', {})
	create_resources(user, $myUsers)
}