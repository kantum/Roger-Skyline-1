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
	iptables -P OUTPUT ACCEPT
	iptables -P FORWARD DROP
	# Allow traffic on loopback
	iptables -A INPUT -i lo -j ACCEPT
	iptables -A OUTPUT -o lo -j ACCEPT
	# Allow ssh
	iptables -A INPUT -p tcp --dport 4242 -j ACCEPT
	iptables -A OUTPUT -p tcp --sport 4242 -j ACCEPT
	# Allow http
	iptables -A INPUT -p tcp --dport 80 -j ACCEPT
	iptables -A OUTPUT -p tcp --sport 80 -j ACCEPT
	# Allow establised connections
	iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
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

# IPV6
	# Set default policy
	ip6tables -P INPUT DROP
	ip6tables -P OUTPUT ACCEPT
	ip6tables -P FORWARD DROP
	# Allow traffic on loopback
	ip6tables -A INPUT -i lo -j ACCEPT
	ip6tables -A OUTPUT -o lo -j ACCEPT
	# Allow ssh
	ip6tables -A INPUT -p tcp --dport 4242 -j ACCEPT
	ip6tables -A OUTPUT -p tcp --sport 4242 -j ACCEPT
	# Allow http
	ip6tables -A INPUT -p tcp --dport 80 -j ACCEPT
	ip6tables -A OUTPUT -p tcp --sport 80 -j ACCEPT
	# Protect ssh against DOS attack
	ip6tables -I INPUT -p tcp --dport 4242 -m state --state NEW -m recent --set
	ip6tables -I INPUT -p tcp --dport 4242 -m state --state NEW -m recent --update --seconds 60 --hitcount $DOS_SSH -j DROP
	# Protect http against DOS attack
	ip6tables -I INPUT -p tcp --dport 80 -m state --state NEW -m recent --set
	ip6tables -I INPUT -p tcp --dport 80 -m state --state NEW -m recent --update --seconds 60 --hitcount $DOS_HTTP -j DROP
	# Protect https against DOS attack
	ip6tables -I INPUT -p tcp --dport 443 -m state --state NEW -m recent --set
	ip6tables -I INPUT -p tcp --dport 443 -m state --state NEW -m recent --update --seconds 60 --hitcount $DOS_HTTPS -j DROP
	# Protect against NULL scan
	ip6tables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP

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
