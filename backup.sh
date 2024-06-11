#!/bin/bash

# Set variables
BACKUP_DIR="/archive"
SSH_CONFIG="/etc/ssh/sshd_config"
RDP_CONFIG="/etc/xrdp"
FTP_CONFIG="/etc/vsftpd.conf"
SSL_KEYS="/etc/ssl" # as part of ftp configuration
LOGS="/var/log"
HOME_DIR="/home/$USER"

# Check if backup directory exists, create if not
if [ ! -d "$BACKUP_DIR" ]; then # setup
	sudo mkdir -p $BACKUP_DIR      # setup
fi                              # setup

# Download, save and make this script executable, if not in /archive dir
if [ ! -f "$BACKUP_DIR/backup.sh" ]; then                                                                                    # setup
	curl -sL https://raw.githubusercontent.com/XelorR/sf_infosec_os_03_administrating-linux/main/backup.sh >$HOME_DIR/backup.sh # setup
	sed -i '/# setup$/d' $HOME_DIR/backup.sh                                                                                    # setup
	sudo mv $HOME_DIR/backup.sh $BACKUP_DIR/backup.sh                                                                           # setup
	sudo chmod +x $BACKUP_DIR/backup.sh                                                                                         # setup
fi                                                                                                                           # setup

# Create a timestamp for the backup file
TIMESTAMP=$(date +%Y-%m-%d)

# Create the backup. If repeated during the same day, save incremently
tar cpNf "$BACKUP_DIR/backup-$TIMESTAMP.tar" --directory / $HOME_DIR $SSH_CONFIG $RDP_CONFIG $FTP_CONFIG $LOGS $SSL_KEYS

# Add cron job if not added
if ! sudo grep -q '30 18 * * 5 $BACKUP_DIR/backup.sh' /var/spool/cron/crontabs/root; then        # setup
	echo "30 18 * * 5 $BACKUP_DIR/backup.sh" | sudo tee -a /var/spool/cron/crontabs/root >/dev/null # setup
fi                                                                                               # setup
