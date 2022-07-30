#!/bin/bash -ex

apt-get update
apt-get install -y \
  apt-transport-https \
  ca-certificates \
  unzip \
  curl \
  wget

# tgswitch
curl -L https://raw.githubusercontent.com/warrensbox/tgswitch/release/install.sh | bash
tgswitch 0.38.6

# tfenv
tfenv_dst=/usr/share/tfenv
mkdir -p "$tfenv_dst"
git clone --depth=1 https://github.com/tfutils/tfenv.git "$tfenv_dst"
ln -s "$tfenv_dst"/bin/* /usr/local/bin/

tfenv use 0.13.3
tfenv install 0.14.11
tfenv install 1.0.11
tfenv install latest

chown -R ubuntu: "$tfenv_dst"

echo "SUCCESS!"
