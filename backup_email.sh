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
zip -r /home/$USER/BackUp.zip klipper_config/* setup_klipper/*	# Делаем бэкап папки
versions
echo -e 'Klipper : '$Klipper' \tMoonraker : '$Moonraker' \tMainsail : '$Mainsail
FROM=sis.8727@gmail.com			# Будет отображаться "От кого"
MAILTO=5796630@mail.ru			# Кому
SMTPSERVER=smtp.gmail.com:587
SMTPLOGIN=sis.8727@gmail.com	# Логин и пароль от учетной записи gmail.com
SMTPPASS=c2h5ohh2oso4
msg='Klipper : '$Klipper' \nMoonraker : '$Moonraker' \nMainsail : '$Mainsail
# Отправляем письмо
/usr/bin/sendEmail -f $FROM -t $MAILTO -o message-charset=utf-8 -a /home/$USER/BackUp.zip -u $tema -m $msg -s $SMTPSERVER -o tls=yes -xu $SMTPLOGIN -xp $SMTPPASS
rm /home/$USER/BackUp.zip		# Удаляем файл backup
