#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y curl
$STD apt-get install -y sudo
$STD apt-get install -y mc
$STD apt-get install -y gnupg
$STD apt-get install -y jsvc
$STD apt-get install -y wget
$STD apt-get install -y openssh-server
msg_ok "Installed Dependencies"

msg_info "Installing Azul Zulu"
wget -qO /etc/apt/trusted.gpg.d/zulu-repo.asc "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xB1998361219BD9C9"
wget -q https://cdn.azul.com/zulu/bin/zulu-repo_1.0.0-3_all.deb
$STD dpkg -i zulu-repo_1.0.0-3_all.deb
$STD apt-get update
$STD apt-get -y install zulu8-jdk
msg_ok "Installed Azul Zulu"

msg_info "Installing MongoDB"
wget -qL http://ports.ubuntu.com/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_arm64.deb
$STD dpkg -i libssl1.1_1.1.1f-1ubuntu2_arm64.deb
wget -qL https://repo.mongodb.org/apt/ubuntu/dists/focal/mongodb-org/4.4/multiverse/binary-arm64/mongodb-org-server_4.4.29_arm64.deb
$STD dpkg -i mongodb-org-server_4.4.29_arm64.deb
msg_ok "Installed MongoDB"

latest_url=$(curl -fsSL "https://www.tp-link.com/en/support/download/omada-software-controller/" | grep -o 'https://.*x64.deb' | head -n1)
latest_version=$(basename "$latest_url")

msg_info "Installing Omada Controller"
wget -qL ${latest_url}
$STD dpkg -i --ignore-depends=jsvc,mongodb-server ${latest_version}
msg_ok "Installed Omada Controller"

motd_ssh
customize

msg_info "Cleaning up"
rm -rf ${latest_version} mongodb-org-server_4.4.29_arm64.deb zulu-repo_1.0.0-3_all.deb libssl1.1_1.1.1f-1ubuntu2_arm64.deb
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
