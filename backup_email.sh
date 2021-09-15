#!/bin/bash
USER='klipper'

versions(){
  cd /home/$USER/klipper/
  Klipper=$(git describe HEAD --always --tags | cut -d "-" -f 1,2)
  cd /home/$USER/moonraker/
  git fetch origin master -q
  Moonraker=$(git describe HEAD --always --tags | cut -d "-" -f 1,2)
  Mainsail=$(head -n 1 /home/$USER/mainsail/.version)
  cd ~
}

data=`date +%Y.%m.%d`
tema='3D Printer Klipper Backup Configs '$data

versions
echo -e "$Klipper"
echo -e "$Moonraker"
echo -e "$Mainsail"
# Делаем бэкап папки
zip -r /home/$USER/BackUp.zip klipper_config/* setup_klipper/*
# Будет отображаться "От кого"
FROM=sis.8727@gmail.com

# Кому
MAILTO=5796630@mail.ru

# В моем примере я отправляю письма через существующий почтовый ящик на gmail.com
# Скрипт легко адаптируется для любых почтовых серверов
SMTPSERVER=smtp.gmail.com:587

# Логин и пароль от учетной записи gmail.com
SMTPLOGIN=sis.8727@gmail.com
SMTPPASS=c2h5ohh2oso4

# Сообщение
msg='Klipper : '$Klipper' \nMoonraker : '$Moonraker' \nMainsail : '$Mainsail

# Отправляем письмо
/usr/bin/sendEmail -f $FROM -t $MAILTO -o message-charset=utf-8 -a /home/$USER/BackUp.zip -u $tema -m $msg -s $SMTPSERVER -o tls=yes -xu $SMTPLOGIN -xp $SMTPPASS

# Удаляем файл backup
rm /home/$USER/BackUp.zip
# crontab -e		0 05 * * * /home/$USER/backup_email.sh