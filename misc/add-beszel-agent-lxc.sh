#!/usr/bin/env bash

# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
    ____                       __      ___                    __ 
   / __ )___  _________  ___  / /     /   | ____ ____  ____  / /_
  / __  / _ \/ ___/_  / / _ \/ /_____/ /| |/ __ `/ _ \/ __ \/ __/
 / /_/ /  __(__  ) / /_/  __/ /_____/ ___ / /_/ /  __/ / / / /_  
/_____/\___/____/ /___/\___/_/     /_/  |_\__, /\___/_/ /_/\__/  
                                         /____/                  
EOF
}
header_info
set -e
while true; do
  read -p "This will add Beszel Agent to an existing LXC Container ONLY. Proceed(y/n)?" yn
  case $yn in
  [Yy]*) break ;;
  [Nn]*) exit ;;
  *) echo "Please answer yes or no." ;;
  esac
done
header_info
echo "Loading..."
function msg() {
  local TEXT="$1"
  echo -e "$TEXT"
}

NODE=$(hostname)
MSG_MAX_LENGTH=0
while read -r line; do
  TAG=$(echo "$line" | awk '{print $1}')
  ITEM=$(echo "$line" | awk '{print substr($0,36)}')
  OFFSET=2
  if [[ $((${#ITEM} + $OFFSET)) -gt ${MSG_MAX_LENGTH:-} ]]; then
    MSG_MAX_LENGTH=$((${#ITEM} + $OFFSET))
  fi
  CTID_MENU+=("$TAG" "$ITEM " "OFF")
done < <(pct list | awk 'NR>1')

while [ -z "${CTID:+x}" ]; do
  CTID=$(whiptail --backtitle "Proxmox VE Helper Scripts" --title "Containers on $NODE" --radiolist \
    "\nSelect a container to add Beszel Agent to:\n" \
    16 $(($MSG_MAX_LENGTH + 23)) 6 \
    "${CTID_MENU[@]}" 3>&1 1>&2 2>&3) || exit
done

CTID_CONFIG_PATH=/etc/pve/lxc/${CTID}.conf
header_info
msg "Installing Beszel Agent..."
pct exec "$CTID" -- bash -c 'curl -sL https://raw.githubusercontent.com/henrygd/beszel/main/supplemental/scripts/install-agent.sh -o  install-beszel-agent.sh && chmod +x install-beszel-agent.sh && ./install-beszel-agent.sh && rm -f ./install-beszel-agent.sh &>/dev/null' || exit
msg "\e[1;32m ✔ Installed Beszel Agent\e[0m"
