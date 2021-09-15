#!/usr/bin/env bash
set -eu

KIAUH_REPO=https://github.com/th33xitus/kiauh.git
TELEGRAM_BOT_REPO=https://github.com/nlef/moonraker-telegram-bot

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

read -p "Install Telegram Bot (y/N):" yn
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

