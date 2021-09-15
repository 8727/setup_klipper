#!/bin/sh

clear
set -e

apt update -y && apt upgrade -y
apt-get install gpiod sendemail libnet-ssleay-perl libio-socket-ssl-perl -y

NEWUSER='klipper'

create_klipper_user(){
  if [[ $(cat /etc/passwd | grep 'klipper' | wc -l) -eq 0 ]]; then
      adduser ${NEWUSER}
  fi
    usermod -a -G tty ${NEWUSER}
    usermod -a -G dialout ${NEWUSER}
    adduser ${NEWUSER} sudo
    echo -e "${NEWUSER} ALL=(ALL) NOPASSWD: ALL \n" >> /etc/sudoers
}

update_udev(){

    /bin/sh -c "cat > /etc/udev/rules.d/99-gpio.rules" <<EOF
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
      groupadd gpio
    fi
    usermod -a -G gpio ${NEWUSER}
    udevadm control --reload-rules
    udevadm trigger
}

create_klipper_user
update_udev
echo -e '0 05 * * * /home/klipper/setup_klipper/backup_email.sh' | crontab -

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
sudo -Hu ${NEWUSER} ${SCRIPT_DIR}/services.sh
