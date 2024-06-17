#!/bin/bash

. /etc/os-release

# 1. check if backports repo enabled and enable if not
if [[ "$ID" = "ubuntu" && "$VERSION_ID" = "24.04" ]]; then
	if grep -qE '^Suites: noble noble-updates noble-backports' /etc/apt/sources.list.d/ubuntu.sources; then
		echo "The 'backports' repository is enabled already."
	else
		echo "The 'backports' repository is not enabled, adding."
		cat <<EOF >~/backports.sources
Types: deb
URIs: http://archive.ubuntu.com/ubuntu
Suites: noble noble-updates noble-backports
Components: main universe restricted multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
EOF
		sudo mv ~/backports.sources /etc/apt/sources.list.d/backports.sources
	fi
else
	echo "In 'backports adding' context, only Ubuntu Noble supported."
fi

# add fish fresh repo
if [ "$ID" = "debian" ]; then
	if [ "$VERSION_ID" = "12" ]; then
		echo Debian 12 detected, adding corresponding Fish repo
		echo 'deb http://download.opensuse.org/repositories/shells:/fish:/release:/3/Debian_12/ /' | sudo tee /etc/apt/sources.list.d/shells:fish:release:3.list
		curl -fsSL https://download.opensuse.org/repositories/shells:fish:release:3/Debian_12/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/shells_fish_release_3.gpg >/dev/null
	elif [ "$VERSION_ID" = "11" ]; then
		echo Debian 11 detected, adding corresponding Fish repo
		echo 'deb http://download.opensuse.org/repositories/shells:/fish:/release:/3/Debian_11/ /' | sudo tee /etc/apt/sources.list.d/shells:fish:release:3.list
		curl -fsSL https://download.opensuse.org/repositories/shells:fish:release:3/Debian_11/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/shells_fish_release_3.gpg >/dev/null
	elif [ "$VERSION_ID" = "10" ]; then
		echo Debian 10 detected, adding corresponding Fish repo
		echo 'deb http://download.opensuse.org/repositories/shells:/fish:/release:/3/Debian_10/ /' | sudo tee /etc/apt/sources.list.d/shells:fish:release:3.list
		curl -fsSL https://download.opensuse.org/repositories/shells:fish:release:3/Debian_10/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/shells_fish_release_3.gpg >/dev/null
	fi
	sudo apt update
elif [ "$ID" = "ubuntu" ]; then
	if [ "$VERSION_ID" = "24.04" ]; then
		echo Ubuntu Noble already contains fresh-enough Fish Shell
	else
		echo Outdated Ubuntu detected, adding Fish ppa
		sudo apt-add-repository ppa:fish-shell/release-3
	fi
fi

# install required packages
if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
	# 2. update package manager
	sudo apt update && sudo apt upgrade -y
	sudo apt install -y apache2 python3-{pip,venv} ssh neovim git fish tmux wget aria2 curl rsync vsftpd xfce4 xrdp zsh && sudo systemctl enable apache2
elif [ "$ID" = "fedora" ]; then
	# exact packages are not tested! specified here as conditional example! everything was tested on ubuntu VM only!
	dnf check-update
	sudo dnf install -y apache2 python3 neovim git fish openssh-server tmux wget aria2 curl rsync vsftpd xfce4 xrdp zsh && sudo systemctl enable --now sshd && sudo systemctl enable apache2
elif [ "$ID" = "opensuse" ]; then
	# exact packages are not tested! specified here as conditional example! everything was tested on ubuntu VM only!
	sudo zypper refresh
	sudo zypper install apache2 python neovim git fish openssh tmux wget aria2 curl rsync vsftpd xfce4 xrdp zsh && sudo systemctl enable --now sshd.service && sudo systemctl enable apache2
elif [ "$ID_LIKE" = "arch" ]; then
	# exact packages are not tested! specified here as conditional example! everything was tested on ubuntu VM only!
	sudo pacman -Syu apache python neovim git fish openssh tmux wget aria2 curl rsync vsftpd xfce4 xrdp zsh && sudo systemctl enable --now sshd && sudo systemctl enable apache2
fi

# generate key if not exists
if [ ! -f ~/.ssh/id_ed25519.pub ]; then
	ssh-keygen -t ed25519
fi

# setup zsh
sudo sed -i "s|^\($USER.*\)/bin/bash|\1/bin/zsh|" /etc/passwd # changing default shell to zsh for current user

cat <<EOF >$HOME/.zshrc
export PATH=~/.local/bin:$PATH

alias ll='ls -lh'
alias la='ll -A'

if command -v emacs &>/dev/null; then
	alias em="emacs -nw -Q --eval '(progn (setq make-backup-files nil) (menu-bar-mode -1))'"
	alias macs="emacsclient -a '' -c -nw"
fi
if command -v nvim &>/dev/null; then
	export VISUAL=nvim
	alias vi='nvim --clean'
fi
export EDITOR=vi

if command -v rsync &>/dev/null; then
	alias cpv='rsync -ah --info=progress2'
fi

tm() {
	if [ $# -eq 0 ]; then
		tmux a || tmux
	else
		tmux a -t $1 || tmux new -s $1
	fi
}
alias tml='tmux list-sessions'
EOF

# lf file manager setup
if [[ "$(uname -m)" == "x86_64" ]]; then
	url="https://github.com/gokcehan/lf/releases/latest/download/lf-linux-amd64.tar.gz"
elif [[ "$(uname -m)" == "aarch64" ]]; then
	url="https://github.com/gokcehan/lf/releases/latest/download/lf-linux-arm64.tar.gz"
fi
archiveName="$(echo $url | cut -d'/' -f9)"

mkdir -p "$HOME/.local/bin"
rm -rf "$HOME/.local/bin/lf"
wget $url
tar xf $archiveName -C "$HOME/.local/bin/"
rm -rf $archiveName

# enabling ftp
cat <<EOF >$HOME/vsftpd.conf
allow_anon_ssl=NO
anonymous_enable=NO
allow_writeable_chroot=YES
chroot_local_user=YES
connect_from_port_20=YES
force_local_data_ssl=YES
force_local_logins_ssl=YES
local_enable=YES
local_umask=022
rsa_cert_file=/etc/ssl/private/ssl-cert-snakeoil.pem
rsa_private_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
ssl_enable=YES
ssl_ciphers=HIGH
ssl_sslv2=NO
ssl_sslv3=NO
ssl_tlsv1=YES
use_localtime=YES
write_enable=YES
xferlog_enable=YES
xferlog_std_format=YES
EOF
sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.orig
sudo mv $HOME/vsftpd.conf /etc/vsftpd.conf
sudo systemctl enable --now vsftpd

# xrdp config
echo xfce4-session >~/.xsession
