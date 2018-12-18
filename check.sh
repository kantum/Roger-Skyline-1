#/bin/sh

# You have to run this file once in order to get the difference

# If MD5 file doesn't exist create it
# If file changed send a mail to root and reset the MD5

if [ ! -e /root/.crontab.md5 ]
then
	md5sum /etc/crontab > $HOME/.crontab.md5
elif ! md5sum -c --status $HOME/.crontab.md5;
then
	printf "There is some changes in /etc/crontab :\n\n" |
	cat - /etc/crontab |
	mail -s "crontab has changed baby" root
	echo `stat -c %z /etc/crontab` >> $HOME/.crontab_watch
	rm $HOME/.crontab.md5
	md5sum /etc/crontab > $HOME/.crontab.md5
fi
