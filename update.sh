#/bin/sh

if [ `id -u` -ne 0 ]
then
	echo "Run this script as root Joe!"
	exit
fi

echo "\n`date`\n" >> /var/log/update_script.log

echo "update"
apt-get update >> /var/log/update_script.log 2>&1
echo "dist-upgrade"
apt-get dist-upgrade >> /var/log/update_script.log 2>&1
echo "upgrade"
apt-get upgrade >> /var/log/update_script.log 2>&1

if [ "$1" = "clean" ]
then
echo "autoremove"
apt-get autoremove >> /var/log/update_script.log 2>&1
echo "autoclean"
apt-get autoclean >> /var/log/update_script.log 2>&1
fi
