#!/usr/bin/env bash
# This script helps to install klipper on orangepi devices

clear
sudo apt update -y && sudo apt upgrade -y
sudo apt-get install gpiod sendemail libnet-ssleay-perl libio-socket-ssl-perl -y

NEWUSER='klipper'

create_klipper_user(){
	if [[ $(cat /etc/passwd | grep 'klipper' | wc -l) -eq 0 ]]; then
	   sudo adduser ${NEWUSER}
	fi
   sudo usermod -a -G tty ${NEWUSER}
   sudo usermod -a -G dialout ${NEWUSER}
   sudo adduser ${NEWUSER} sudo
   sudo echo -e "${NEWUSER} ALL=(ALL) NOPASSWD: ALL\n" >> /etc/sudoers
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

create_klipper_user
update_udev

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
sudo -Hu ${NEWUSER} ${SCRIPT_DIR}/services.sh
