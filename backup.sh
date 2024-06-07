#!/bin/bash

# Set variables
BACKUP_DIR="/archive"
SSH_CONFIG="/etc/ssh/sshd_config"
RDP_CONFIG=""                 # Replace with RDP configuration file path if it exists
FTP_CONFIG="/etc/vsftpd.conf" # Replace with FTP configuration file path if it exists
LOGS="/var/log"
HOME_DIR="/home/$USER"

# Check if backup directory exists, create if not
if [ ! -d "$BACKUP_DIR" ]; then
	sudo mkdir -p $BACKUP_DIR
fi

# Download, save and make this script executable, if not in /archive dir
if [ ! -f "$BACKUP_DIR/backup.sh" ]; then
	curl -sL https://raw.githubusercontent.com/XelorR/sf_infosec_os_03_administrating-linux/main/backup.sh >$HOME_DIR/backup.sh
	sudo mv $HOME_DIR/backup.sh $BACKUP_DIR/backup.sh
	sudo chmod +x $BACKUP_DIR/backup.sh
fi

# Create a timestamp for the backup file
TIMESTAMP=$(date +%Y-%m-%d)

# Create the backup. If repeated during the same day, save incremently
tar cpNf "$BACKUP_DIR/backup-$TIMESTAMP.tar" $HOME_DIR $SSH_CONFIG $RDP_CONFIG $FTP_CONFIG $LOGS

# to do it conditionally from the script
# crontab -e
# Minute Hour Day Month Weekday
# 30 18 * * 5 $BACKUP_DIR/backup.sh
