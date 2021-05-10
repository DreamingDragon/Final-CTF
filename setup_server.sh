#!/bin/bash

echo "Installing server..."
/share/education/TCPSYNFlood_USC_ISI/install-server
echo "Installed."

echo "Searching for gateway interface..."
ETH=$(./eth_getter.sh 10.1.5.3)
echo "Found interface on $ETH."

iptables -N from_gateway
iptables -A INPUT -i $ETH -j from_gateway
iptables -N tcp_from_gateway
iptables -A from_gateway -p tcp -j tcp_from_gateway

iptables -N to_gateway
iptables -A OUTPUT -o $ETH -j to_gateway
iptables -N tcp_to_gateway
iptables -A to_gateway -p tcp -j tcp_to_gateway

echo "Blocking NULL packets..."
sudo iptables -A tcp_from_gateway --tcp-flags ALL NONE -j DROP
echo "Blocked."

echo "Blocking Christmas attacks..."
sudo iptables -A tcp_from_gateway --tcp-flags ALL ALL -j DROP
sudo iptables -A tcp_from_gateway --tcp-flags ALL FIN,PSH,URG -j DROP
echo "Festivus mode engaged."

echo "Preventing sockstress..."
sudo iptables -A tcp_from_gateway --dport 80 -m state --state NEW -m recent --set
sudo iptables -A tcp_from_gateway --dport 80 -m state --state NEW -m recent --update --seconds 2 --hitcount 4 -j DROP
echo "Socks sewn up."

echo "Mitigating slowloris..."
sudo iptables -A tcp_from_gateway -dport 80 -m connlimit --connlimit-above 20 --connlimit-mask 30 -j DROP
echo "Loris caffeinated."

echo "Ignoring RST floods..."
sudo iptables -A tcp_from_gateway --tcp-flags RST RST -j DROP
echo "Dam emplaced."

echo "Preventing SYN floods..."
sudo iptables -A tcp_from_gateway --syn -m state --state NEW -j DROP
echo "Holland shall stay dry this day."

echo "Allowing limited client connections..."
sudo iptables -A tcp_from_gateway -s client1 -m multiport --dports 80,22,443 -m limit 2/s -j ACCEPT
sudo iptables -A tcp_to_gateway -d client1 -m multiport -dports 80,22,443 -m state --state RELATED,ESTABLISHED -j ACCEPT

sudo iptables -A tcp_from_gateway -s client2 -m multiport --dports 80,22,443 -m limit 2/s -j ACCEPT
sudo iptables -A tcp_to_gateway -d client2 -m multiport -dports 80,22,443 -m state --state RELATED,ESTABLISHED -j ACCEPT

sudo iptables -A tcp_from_gateway -s client3 -m multiport --dports 80,22,443 -m limit 2/s -j ACCEPT
sudo iptables -A tcp_to_gateway -d client3 -m multiport -dports 80,22,443 -m state --state RELATED,ESTABLISHED -j ACCEPT
echo "Clients cautiously allowed in."

echo "Banning all other traffic..."
sudo iptables -A from_gateway -j DROP
sudo iptables -A to_gateway -j DROP
sudo iptables -A from_gateway -s gateway -j DROP # Is this one necessary? Feels like it should alreay be handled by the drop-everything clause.
