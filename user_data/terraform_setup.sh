#!/bin/bash -ex

DEFAULT_USER=ubuntu

apt-get update
apt-get install -y \
  apt-transport-https \
  ca-certificates \
  unzip \
  curl \
  make \
  wget

#
# tgswitch
#
curl -L https://raw.githubusercontent.com/warrensbox/tgswitch/release/install.sh | bash
sudo -u $DEFAULT_USER tgswitch 0.38.6

#
# tfenv
#
tfenv_dst=/usr/share/tfenv
mkdir -p "$tfenv_dst"
git clone --depth=1 https://github.com/tfutils/tfenv.git "$tfenv_dst"
ln -s "$tfenv_dst"/bin/* /usr/local/bin/

tfenv use 0.13.3
tfenv install 0.14.11
tfenv install 1.0.11
tfenv install latest

chown -R $DEFAULT_USER: "$tfenv_dst/versions" "$tfenv_dst/version"

#
# sshd
#
echo 'AcceptEnv AWS_ACCESS_KEY_ID' >> /etc/ssh/sshd_config
echo 'AcceptEnv AWS_SECRET_ACCESS_KEY' >> /etc/ssh/sshd_config
systemctl reload sshd

#
# gitbud
#
sudo -u $DEFAULT_USER sh -c 'ssh-keyscan gitbud.epam.com >> ~/.ssh/known_hosts'

#
# zsh
#
apt-get install -y zsh
chsh -s "/usr/bin/zsh" $DEFAULT_USER

sudo -u $DEFAULT_USER sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
sudo -u $DEFAULT_USER sh -c "git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"

sudo -u $DEFAULT_USER sh -c 'echo export PATH=\"\${HOME}/bin:\${PATH}\" >> ~/.zshrc'
sudo -u $DEFAULT_USER sh -c 'sed -i "s/ZSH_THEME=.*/ZSH_THEME=\"gnzh\"/g" ~/.zshrc'
sudo -u $DEFAULT_USER sh -c 'sed -i "s/plugins=.*/plugins=\(git colorize zsh-autosuggestions\)/g" ~/.zshrc'

# terraform exit trigger
echo "SUCCESS!"
