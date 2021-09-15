#!/bin/sh

clear
set -e

KIAUH_REPO=https://github.com/th33xitus/kiauh.git
TELEGRAM_BOT_REPO=https://github.com/nlef/moonraker-telegram-bot

#sudo apt update && sudo apt upgrade -y
sudo apt-get install gpiod sendemail libnet-ssleay-perl libio-socket-ssl-perl

NEWUSER='klipper'

create_klipper_user(){
  if [[ $(cat /etc/passwd | grep 'klipper' | wc -l) -eq 0 ]]; then
    sudo adduser ${NEWUSER}
  fi
  sudo usermod -a -G tty ${NEWUSER}
  sudo usermod -a -G dialout ${NEWUSER}
  sudo adduser ${NEWUSER} sudo
  #sudo echo -e "${NEWUSER} ALL=(ALL) NOPASSWD: ALL \n" >> /etc/sudoers
}

update_udev(){
  sudo /bin/sh -c "cat > /etc/udev/rules.d/99-gpio.rules" <<EOF
# Corrects sys GPIO permissions so non-root users in the gpio group can manipulate bits
#
SUBSYSTEM=="gpio", GROUP="gpio", MODE="0660"
SUBSYSTEM=="gpio*", PROGRAM="/bin/sh -c '\
 chown -R root:gpio /sys/class/gpio && chmod -R 770 /sys/class/gpio;\
 chown -R root:gpio /sys/devices/virtual/gpio && chmod -R 770 /sys/devices/virtual/gpio;\
 chown -R root:gpio /sys$devpath && chmod -R 770 /sys$devpath\'"
EOF

  # execute udev rules?!
  if [[ `cat /etc/group | grep 'gpio' | wc -l` -eq 0 ]]; then
    sudo groupadd gpio
  fi
  sudo usermod -a -G gpio ${NEWUSER}
  sudo udevadm control --reload-rules
  sudo udevadm trigger
}

download_kiauh(){
  cd  ~
  KIAUH_FOLDER=kiauh
  if [ ! -d "${KIAUH_FOLDER}" ] ; then
    git clone ${KIAUH_REPO} ${KIAUH_FOLDER}
    cd "${KIAUH_FOLDER}"
  else
    cd "${KIAUH_FOLDER}"
    git pull ${KIAUH_REPO}
  fi
  ./kiauh.sh || :
}

install_telegram_bot(){
  cd  ~
  TBOT_FOLDER=moonraker-telegram-bot
  if [ ! -d "${TBOT_FOLDER}" ] ; then
    git clone ${TELEGRAM_BOT_REPO} ${TBOT_FOLDER}
      cd "${TBOT_FOLDER}/scripts/"
  else
      cd "${TBOT_FOLDER}/scripts/"
      git pull ${TELEGRAM_BOT_REPO}
  fi
  ./install.sh
}


sudo create_klipper_user
sudo update_udev
read -p "download kiauh(y/N):" yn
while true; do
  case "$yn" in
  Y|y|Yes|yes)
    download_kiauh
  break;;
  N|n|No|no|"") break;;
  *) break;;
  esac
  done

read -p "Install Telegram Bot kiauh(y/N):" yn
while true; do
  case "$yn" in
  Y|y|Yes|yes)
    install_telegram_bot
  break;;
  N|n|No|no|"") break;;
  *) break;;
  esac
  done

sudo sh /home/klipper/moonraker/scripts/sudo_fix.sh
echo "0 05 * * * /home/${NEWUSER}/backup_email.sh" | crontab -e
