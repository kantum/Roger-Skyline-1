#/bin/sh

if [ "$1" = "create" ]
then
	md5sum /etc/crontab > $HOME/.crontab.md5
elif [ !  `md5sum -c --status $HOME/.crontab.md5` ]
then
	printf "There is some changes in /etc/crontab :\n\n" |
	cat - /etc/crontab |
	mail -s "crontab has changed baby" root
	echo `stat -c %Z /etc/crontab` > $HOME/.crontab_watch
fi
