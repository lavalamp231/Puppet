# Class: bind_server
#
#
class bind_server {
    # resources


class { 'bind':
    forwarders => [
        '8.8.8.8',
        '8.8.4.4',
    ],
    dnssec     => true,
    version    => 'Controlled by Puppet',
}

bind::acl { 'rfc1918':
    addresses => [
        '192.168.0.0/24',
    ]
}


Resource_record <<| |>> # This will collect from "dnsexport.pp and create all of the resource records for each host"


# Splat for resource record

$my_resource_record = {
    ensure  => present,
    record  => ${facts['hostname']}, # Getting the DNS severs's hostname address
    type    => 'NS',
    data    => ${facts['ipaddress']}, # Getting the DNS server's IP address
    ttl     => 86400, 
}

# NS

resource_record { 'esxi.com ns records':
    *       => $my_resource_record,
    zone    => 'esxi.com',
}

resource_record { '0.168.192.in-addr.arpa ns records':
    *       => $my_resource_record,
    zone    => '0.168.192.in-addr.arpa',
}

}