$commands = ['rsync -av /Storage2/TV-Shows/ /Backup/plex/TV-Shows/', 'rsync -av /Storage2/Movies/ /Backup/plex/Movies/']

$plex_resource_attributes = {
	user     => 'root',
	month    => '*',
	monthday => '*',
	hour     => '2',
	minute   => '30',
}

class my_crons {
# resources

# Plex backup -  Plex to Storage2

cron { 'plex_backup_tv_shows':
	command  => '/local_scripts/backup_plex.sh',
	* => $plex_resource_attributes,
}

#cron { 'plex_backup_movies':
#	command  => 'rsync -av /Storage2/Movies/ /Plex_backup/Movies/',
#	* => $plex_resource_attributes,
#}

# Setting permissions on directories /Storage, /Storage2, /Backup

cron { 'storage_permissions_chown':
	command  => 'chown -R Andrew:sambagroup /Storage /Storage2 /Backup',
	user     => 'root',
	month    => '*',
	monthday => '*',
	hour     => '*',
	minute   => '30',
}

cron { 'storage_permissions_chmod':
	command  => 'chmod 775 -R /Storage /Storage2 /Backup',
	user     => 'root',
	month    => '*',
	monthday => '*',
	hour     => '*',
	minute   => '30',
}


################### Performance stats ######################



cron { 'iostat_storage':
	command  => '/Misc/Scripts/cronjobs/iostat.sh',
	user     => 'root',
	month    => '*',
	monthday => '*',
	hour     => '*',
	minute   => '50',
}

}


