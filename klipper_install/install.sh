#!/bin/sh
USER='klipper'
clear
echo "                        \033[1;32m Настройка прав\033[m"

sudo apt-get update && sudo apt-get install sendemail libnet-ssleay-perl libio-socket-ssl-perl

echo "0 05 * * * /home/$USER/backup_email.sh" | crontab -e