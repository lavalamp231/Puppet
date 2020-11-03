class graylog_server {

class { 'mongodb::globals':
  manage_package_repo => true,
}->
class { 'mongodb::server':
  bind_ip => ['127.0.0.1'],
}

class { 'elasticsearch':
  version      => '2.3.2',
  repo_version => '2.x',
  manage_repo  => true,
}->
elasticsearch::instance { 'graylog':
  config => {
    'cluster.name' => 'graylog',
    'network.host' => '192.168.0.9',
  }
}

class { 'graylog::repository':
  version => '2.1'
}->
class { 'graylog::server':
  package_version => '2.1.0-9',
  config          => {
    'password_secret' => 'ryf3eDTmryDgPSxPsOam7swIZx7BtfLpnMd1I4aQzn9to2HiXhuAtx1EEApcoLhEnVlCsjpb8otKilbza15Ji4wGBNKP77cX',    # Fill in your password secret
    'root_password_sha2' => '035fa1097c22c896dd86049fd83c0f7a326fa1b98351249b00f46d1480c6bd24', # Fill in your root password hash
  	'rest_listen_uri'	=> 'http://192.168.0.9:12900/',
  	'web_listen_uri' => 'http://192.168.0.9:9000/',
  	'elasticsearch_discovery_zen_ping_unicast_hosts' => '192.168.0.9:9300',
  	'elasticsearch_max_docs_per_index' => '20000000',
    'elasticsearch_max_number_of_indices' => '20',
    'elasticsearch_shards' => '2',
    'elasticsearch_replicas' => '1',
    'timezone' => '"America/Chicago"',
  }
}

}