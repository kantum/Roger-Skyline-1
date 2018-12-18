#!/bin/sh

if [ `id -u` -ne 0 ]
then
	echo "Run this script as root motherfucker"
	exit
fi

# Flushing all rules
iptables -F
iptables -X

# Set how many connections before blocking DOS attack
DOS_SSH=20
DOS_HTTP=20
DOS_HTTPS=20

if [ "$#" -eq 0 ]
then
	# Set default policy
	iptables -P INPUT DROP
	iptables -P OUTPUT DROP
	iptables -P FORWARD DROP
	# Allow traffic on loopback
	iptables -A INPUT -i lo -j ACCEPT
	iptables -A OUTPUT -o lo -j ACCEPT
	# Allow output connection for icmp
	iptables -A INPUT -p icmp -j ACCEPT
	iptables -A OUTPUT -p icmp -j ACCEPT
	# Allow DNS
	sudo iptables -t filter -A OUTPUT -p tcp --dport 53 -j ACCEPT
	sudo iptables -t filter -A OUTPUT -p udp --dport 53 -j ACCEPT
	sudo iptables -t filter -A INPUT -p tcp --dport 53 -j ACCEPT
	sudo iptables -t filter -A INPUT -p udp --dport 53 -j ACCEPT
	# Allow outgoing http
	iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
	# Allow outgoing https
	iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT
	# Allow outgoing ftp
	iptables -A OUTPUT -p tcp --dport 21 -j ACCEPT
	# Allow incomming ssh
	iptables -A INPUT -p tcp --dport 4242 -j ACCEPT
	iptables -A OUTPUT -p tcp --sport 4242 -j ACCEPT
	# Allow incomming http
	iptables -A INPUT -p tcp --dport 80 -j ACCEPT
	iptables -A OUTPUT -p tcp --sport 80 -j ACCEPT
	# Allow incomming https
	iptables -A INPUT -p tcp --dport 443 -j ACCEPT
	iptables -A OUTPUT -p tcp --sport 443 -j ACCEPT
	# Allow NTP (server clock)
	sudo iptables -t filter -A OUTPUT -p udp --dport 123 -j ACCEPT
	# Protect ssh against DOS attack
	iptables -I INPUT -p tcp --dport 4242 -m state --state NEW -m recent --set
	iptables -I INPUT -p tcp --dport 4242 -m state --state NEW -m recent --update --seconds 60 --hitcount $DOS_SSH -j DROP
	# Protect http against DOS attack
	iptables -I INPUT -p tcp --dport 80 -m state --state NEW -m recent --set
	iptables -I INPUT -p tcp --dport 80 -m state --state NEW -m recent --update --seconds 60 --hitcount $DOS_HTTP -j DROP
	# Protect https against DOS attack
	iptables -I INPUT -p tcp --dport 443 -m state --state NEW -m recent --set
	iptables -I INPUT -p tcp --dport 443 -m state --state NEW -m recent --update --seconds 60 --hitcount $DOS_HTTPS -j DROP
	# Protect against NULL scan
	iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP

	# Log attacks
	iptables -A INPUT -p tcp --tcp-flags ALL FIN,PSH,URG -m limit --limit 3/m --limit-burst 5 -j LOG --log-prefix "Firewall> XMAS scan "
	iptables -A INPUT -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -m limit --limit 3/m --limit-burst 5 -j LOG --log-prefix "Firewall> XMAS-PSH scan "
	iptables -A INPUT -p tcp --tcp-flags ALL ALL -m limit --limit 3/m --limit-burst 5 -j LOG --log-prefix "Firewall> XMAS-ALL scan "
	iptables -A INPUT -p tcp --tcp-flags ALL FIN -m limit --limit 3/m --limit-burst 5 -j LOG --log-prefix "Firewall> FIN scan "

	# Drop and blacklist for 60 seconds IP of attacker
	# Xmas-PSH scan
	iptables -A INPUT -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -m recent --name blacklist_60 --set  -m comment --comment "Drop/Blacklist Xmas/PSH scan" -j DROP
	# Against nmap -sX (Xmas tree scan)
	iptables -A INPUT -p tcp --tcp-flags ALL FIN,PSH,URG -m recent --name blacklist_60 --set  -m comment --comment "Drop/Blacklist Xmas scan" -j DROP
	# Xmas All scan
	iptables -A INPUT -p tcp --tcp-flags ALL ALL -m recent --name blacklist_60 --set  -m comment --comment "Drop/Blacklist Xmas/All scan" -j DROP
	# FIN scan
	iptables -A INPUT -p tcp --tcp-flags ALL FIN -m recent --name blacklist_60 --set  -m comment --comment "Drop/Blacklist FIN scan" -j DROP

	# Allow establised connections
	iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
elif [ "$1" = "allow" ]
then
	# Accept everything
	iptables -P INPUT ACCEPT
	iptables -P OUTPUT ACCEPT
	iptables -P FORWARD ACCEPT
elif [ "$1" = "deny" ]
then
	# Deny everything
	iptables -P INPUT DROP
	iptables -P OUTPUT DROP
	iptables -P FORWARD DROP
	# Allow ssh
	iptables -A INPUT -p tcp --dport 4242 -j ACCEPT
	iptables -A OUTPUT -p tcp --sport 4242 -j ACCEPT
fi

# Save the configuration
sh -c "iptables-save > /etc/iptables.rules"
