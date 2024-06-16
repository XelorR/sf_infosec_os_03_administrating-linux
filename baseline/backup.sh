#!/bin/bash

# create backup script
sudo mkdir -p /archive
sudo cat <<EOF >/archive/backup.sh
#!/bin/bash

cd /
tar cpf "/archive/backup-\$(date +%Y-%m-%d_%H%M%S).tar" --exclude="\$HOME/.*" /etc/ssh/sshd_config /etc/xrdp /etc/vsftpd.conf /etc/ssh/sshd_config /var/log "\$HOME"
EOF
sudo chmod +x /archive/backup.sh
sudo mkdir -p /archive

# create cron job
if ! sudo crontab -l | grep -q '30 18 \* \* 5 /archive/backup.sh'; then
	sudo crontab -l | {
		cat
		echo '30 18 * * 5 /archive/backup.sh'
	} | sudo crontab -
fi

# run script once, for screenshot
sudo /archive/backup.sh
