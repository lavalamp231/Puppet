# Class: dns_export

#
class dns_export {

###Variables### 

$reverseip = $::ipaddress.reverse # reversing the IP address for PTR 
$ptrrecord = "${reverseip}.in-addr.arpa." # reverse IP + .in-addr.arpa
$arecord = "${::ipaddress}." # ipaddress + . 
$hostnamewithperiod = "${hostname}." # hostname + . 

###############
	
# The goal of this is to dynamically update any node that is attached to puppet by using puppet exported resources. Any time
# a puppet node connects it will check to see if a resource (A, PTR, NS records) is created. 

# PTR Records

@@resource_record {"0.168.192.in-addr.arpa_records_${::hostname}": # to ensure I don't have duplicate resources I added the hostname fact
    ensure  => present,
    record  => $hostnamewithperiod,
    type    => 'PTR',
    data    => $ptrrecord,   
    ttl     => 86400,
    zone    => '0.168.192.in-addr.arpa',
}

# A records

@@resource_record { "esxi.com_a_records_${::hostname}": # to ensure I don't have duplicate resources I added the hostname fact
    ensure  => present,
    record  => $hostnamewithperiod, # hostname with a . at the end
    type    => 'A',
    data    => $::ipaddress, # will gather all nodes ipaddresses
    ttl     => 86400,
    zone    => 'esxi.com',
}


} # Close class