node default {
    contain roles::base
}

node 'canary.esxi.com' {
    contain roles::zabbix
}  
