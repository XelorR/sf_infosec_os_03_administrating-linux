#!/bin/bash

# ПРАКТИЧЕСКОЕ ЗАДАНИЕ №3
# Настройте автоматическую отправку по почте логов изученных сервисов: SSH, FTP, RDP.
#
# УСЛОВИЯ РЕАЛИЗАЦИИ
# Используйте утилиту Logwatch и планировщик задач cron.
# Письмо должно отправляться каждый день в 8:00.
# Уровень детализации — на ваше усмотрение.
# В качестве ответа приложите:
#
# Текст задачи в cron.
# Команду для утилиты Logwatch (в отдельном текстовом файле).
# Скриншот полученного письма.
# Файлы загрузите на GitHub в отдельную от предыдущих пунктов папку.

# Update package list and install logwatch
sudo apt-get update
sudo apt-get install -y logwatch

# Create logwatch configuration file
cat >/etc/logwatch/conf/logwatch.conf <<EOF
# Logwatch Configuration
#
# Set output format to email
OUTPUTFORMAT=email

# Set the recipient email address
EMAIL=youremail@example.com

# Specify log files to watch
LOGFILES="/var/log/auth.log /var/log/secure /var/log/xferlog"

# Specify services to watch
SERVICES="sshd vsftpd sshd"

# Set time period for log analysis
TIMEPERIOD=Daily

# Set time zone
TZ=Europe/Moscow

# Set logwatch to run as root
USER=root
EOF

# Add cron job for logwatch execution
(
	crontab -l
	echo "0 8 * * * /usr/sbin/logwatch --config=/etc/logwatch/conf/logwatch.conf"
) | crontab -

# Send initial test email
/usr/sbin/logwatch --config=/etc/logwatch/conf/logwatch.conf

echo "Logwatch configuration and cron job setup completed."
