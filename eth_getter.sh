#!/bin/bash
function trial() {
	ip_route=$(ip route get 10.1.5.3)
	ip_isolate_eth=’(eth[0-9])’
	[[ $ip_route =~ $ip_isolate_eth ]]
	ETH=${BASH_REMATCH[1]}
	echo “$ETH”
}
