#/bin/sh

# Run update.sh everyday at 4 in the morning and reboot
echo "0 4 * * 1 /root/update.sh
@reboot /root/update.sh" | crontab -

# Run check every night at midnight
echo "0 0 * * * $HOME/.script/crontab_watch.sh" | crontab -
