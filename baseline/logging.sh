#!/bin/bash

# install lowatch
sudo apt update
sudo apt install -y logwatch mailutils

# prepare email template and logwatch command, save as script
sudo mkdir -p /archive
sudo cat <<'EOF' >/archive/logwatch.sh
#!/bin/bash

logwatch --detail Med --mailto petr --service sshd,vsftpd,xrdp --range yesterday
EOF
sudo chmod +x /archive/logwatch.sh

# schedule cron job
if ! sudo crontab -l | grep -q '0 8 \* \* \* /archive/logwatch.sh'; then
	sudo crontab -l | {
		cat
		echo '0 8 * * * /archive/logwatch.sh'
	} | sudo crontab -
fi

# force run script, for screenshot
/archive/logwatch.sh

# check mail for screenshot
# mail
