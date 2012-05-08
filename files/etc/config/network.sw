config 'switch' 'eth0'

config 'switch_vlan' 'eth0_0'
	option 'device' 'eth0'
	option 'vlan' '0'
	option 'ports' '4 5'

config 'switch_vlan' 'eth0_1'
	option 'device' 'eth0'
	option 'vlan' '1'
	option 'ports' '0 1 2 3 5'

config 'interface' 'loopback'
	option 'ifname' 'lo'
	option 'proto' 'static'
	option 'ipaddr' '127.0.0.1'
	option 'netmask' '255.0.0.0'

config 'interface' 'lan'
	option 'type' 'bridge'
	option 'ifname' 'eth0.1'
	option 'proto' 'static'
	option 'ipaddr' '10.11.250.1'
	option 'netmask' '255.255.255.0'

config 'interface' 'wan'
	option 'ifname' 'eth0.0'
	option 'proto' 'dhcp'
	#option 'proto' 'static'
	#option 'ipaddr' '10.1.10.2'
	#option 'netmask' '255.255.255.0'
	#option 'gateway' '10.1.10.1'
	#option 'dns' '10.1.10.1'

