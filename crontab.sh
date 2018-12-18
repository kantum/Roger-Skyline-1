#/bin/sh

# Run update.sh every monday at 4 in the morning
# Run update.sh on reboot
# Run check every night at midnight
echo "0 4 * * 1 /root/update.sh
@reboot /root/update.sh
0 0 * * * /root/check.sh" | crontab -
