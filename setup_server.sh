#!/bin/bash

echo "Installing server..."
/share/education/TCPSYNFlood_USC_ISI/install-server
echo "Installed."

echo "Searching for gateway interface..."
ETH=$(./eth_getter.sh 10.1.5.3)
echo "Found interface on $ETH."

echo "Cleaning house..."
sudo iptables --flush 
echo "Pristine surface to build on."

#Ignores all udp and icmp traffic  
echo "Ignoring packets for unrelated protocols..."
sudo iptables -A INPUT -i $ETH -p udp -j DROP    
sudo iptables -A INPUT -i $ETH -p icmp -j DROP  
sudo iptables -A OUTPUT -o $ETH -p udp -j DROP
echo "Ignored."

#Blocks null packets  
echo "Blocking null packets..."
sudo iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
echo "Blocked."

#Blocks XMAS packets  
echo "Blocking Christmas attacks..."
sudo iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP  
echo "Festivus mode engaged."

#Ignores internal packets in the server (server and gateway)  
echo "Ignoring guileless spoofing..."
#$sudo iptables -A INPUT -s gateway -j DROP
echo "Ignored."

#Block syn flood attack  
echo "Blocking SYN floods..."
sudo iptables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP 
echo "Floodwalls in place."

#Block new packets that are not syn  
echo "Blocking guileless unexpected NEW packets..."
sudo iptables -t mangle -A PREROUTING -p tcp ! --syn -m conntrack --ctstate NEW -j DROP
echo "Blocked."

#block teardrop  
echo "Blocking teardrop..."
sudo iptables -A INPUT -p UDP -f -j DROP
sudo iptables -A OUTPUT -p UDP -f -j DROP  
sudo iptables -A INPUT -p UDP -m length --length 1500 -j DROP  
sudo iptables -A INPUT -p UDP -m length --length 58 -j DROP  
sudo iptables -A OUTPUT -p UDP -m length --length 1500 -j DROP  
sudo iptables -A OUTPUT -p UDP -m length --length 58 -j DROP
echo "Dry-eye mode engaged."

#Block packets with invalid tcp flags 
echo "Blocking bad TCP flags..."
sudo iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j DROP 
sudo iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP  
sudo iptables -t mangle -A PREROUTING -p tcp --tcp-flags SYN,RST SYN,RST -j DROP 
sudo iptables -t mangle -A PREROUTING -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP 
sudo iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,RST FIN,RST -j DROP 
sudo iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,ACK FIN -j DROP 
sudo iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,URG URG -j DROP 
sudo iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,FIN FIN -j DROP 
sudo iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,PSH PSH -j DROP  
sudo iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL ALL -j DROP  
sudo iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL NONE -j DROP
sudo iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL FIN,PSH,URG -j DROP  
sudo iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL SYN,FIN,PSH,URG -j DROP  
sudo iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP
echo "No flags of convenience in this port."

#Sockstress defense  
echo "Lowering sockstress..."
sudo iptables -A INPUT -p tcp --dport 80 -m state --state NEW -m recent --set 
sudo iptables -A INPUT -p tcp --dport 80 -m state --state NEW -m recent --update --seconds 2 --hitcount 4 -j DROP  
echo "Socks sewn up."

#Maybe stop spoofing  
echo "Attempting to prevent spoofs..."
sudo iptables -t mangle -I PREROUTING -p tcp -m tcp --dport 80 -m state --state NEW -m tcpmss ! --mss 536:65535 -j DROP  
echo "Fingers crossed."

#Defend against Slowloris  
echo "Mitigating slowloris..."
sudo iptables -A INPUT -p tcp --syn --dport 80 -m connlimit --connlimit-above 20 -j DROP  
echo "Loris caffeinated."

#Prevent DoS attacks  
echo "Preventing DoS..."
sudo iptables -A INPUT -p tcp --dport 80 -m limit --limit 2/s -j ACCEPT  
sudo iptables -A INPUT -p tcp --dport 22 -m limit --limit 2/s -j ACCEPT  
sudo iptables -A INPUT -p tcp --dport 443 -m limit --limit 2/s -j ACCEPT  
echo "DOS replaced by Unix."

#Accepts new tcp connections  
echo "Allowing clients in..."
sudo iptables -A INPUT -s client1 -i $ETH -m state --state NEW -p tcp --dport 22 -j ACCEPT  
sudo iptables -A INPUT -s client1 -i $ETH -m state --state NEW -p tcp --dport 80 -j ACCEPT  
sudo iptables -A INPUT -s client1 -i $ETH -m state --state NEW -p tcp --dport 443 -j ACCEPT  
sudo iptables -A OUTPUT -d client1 -o $ETH -m state --state NEW -p tcp --dport 22 -j ACCEPT  
sudo iptables -A OUTPUT -d client1 -o $ETH -m state --state NEW -p tcp --dport 80 -j ACCEPT  
sudo iptables -A OUTPUT -d client1 -o $ETH -m state --state NEW -p tcp --dport 443 -j ACCEPT  
sudo iptables -A INPUT -s client2 -i $ETH -m state --state NEW -p tcp --dport 22 -j ACCEPT  
sudo iptables -A INPUT -s client2 -i $ETH -m state --state NEW -p tcp --dport 80 -j ACCEPT  
sudo iptables -A INPUT -s client2 -i $ETH -m state --state NEW -p tcp --dport 443 -j ACCEPT  
sudo iptables -A OUTPUT -d client2 -o $ETH -m state --state NEW -p tcp --dport 22 -j ACCEPT  
sudo iptables -A OUTPUT -d client2 -o $ETH -m state --state NEW -p tcp --dport 80 -j ACCEPT  
sudo iptables -A OUTPUT -d client2 -o $ETH -m state --state NEW -p tcp --dport 443 -j ACCEPT 
sudo iptables -A INPUT -s client3 -i $ETH -m state --state NEW -p tcp --dport 22 -j ACCEPT  
sudo iptables -A INPUT -s client3 -i $ETH -m state --state NEW -p tcp --dport 80 -j ACCEPT  
sudo iptables -A INPUT -s client3 -i $ETH -m state --state NEW -p tcp --dport 443 -j ACCEPT  
sudo iptables -A OUTPUT -d client3 -o $ETH -m state --state NEW -p tcp --dport 22 -j ACCEPT  
sudo iptables -A OUTPUT -d client3 -o $ETH -m state --state NEW -p tcp --dport 80 -j ACCEPT  
sudo iptables -A OUTPUT -d client3 -o $ETH -m state --state NEW -p tcp --dport 443 -j ACCEPT 
sudo iptables -A INPUT -s server -i $ETH -m state --state NEW -p tcp --dport 22 -j ACCEPT 
sudo iptables -A INPUT -s server -i $ETH -m state --state NEW -p tcp --dport 80 -j ACCEPT  
sudo iptables -A INPUT -s server -i $ETH -m state --state NEW -p tcp --dport 443 -j ACCEPT  
sudo iptables -A OUTPUT -d server -o $ETH -m state --state NEW -p tcp --dport 22 -j ACCEPT  
sudo iptables -A OUTPUT -d server -o $ETH -m state --state NEW -p tcp --dport 80 -j ACCEPT  
sudo iptables -A OUTPUT -d server -o $ETH -m state --state NEW -p tcp --dport 443 -j ACCEPT
echo "Legitimate traffic should be allowed."

#Allows traffic to pass from previously accepted connection
echo "Allowing connections to continue..."
sudo iptables -A INPUT -s client1 -i $ETH -m state --state RELATED,ESTABLISHED -j ACCEPT  
sudo iptables -A OUTPUT -d client1 -o $ETH -m state --state RELATED,ESTABLISHED -j ACCEPT  
sudo iptables -A INPUT -s client2 -i $ETH -m state --state RELATED,ESTABLISHED -j ACCEPT  
sudo iptables -A OUTPUT -d client2 -o $ETH -m state --state RELATED,ESTABLISHED -j ACCEPT 
sudo iptables -A INPUT -s client3 -i $ETH -m state --state RELATED,ESTABLISHED -j ACCEPT  
sudo iptables -A OUTPUT -d client3 -o $ETH -m state --state RELATED,ESTABLISHED -j ACCEPT  
sudo iptables -A INPUT -s server -i $ETH -m state --state RELATED,ESTABLISHED -j ACCEPT  
sudo iptables -A OUTPUT -d server -o $ETH -m state --state RELATED,ESTABLISHED -j ACCEPT
echo "Shouldn't cut off mid-sentence anymore."

#Passively ignore all other traffic  
echo "Ignoring all other traffic..."
sudo iptables -A INPUT -i $ETH -j DROP  
sudo iptables -A OUTPUT -o $ETH -j DROP
echo "Road closed."

echo "Firewall in place."
