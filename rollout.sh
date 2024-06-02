#!/bin/bash

. /etc/os-release

# 1. check if backports repo enabled and enable if not
if [ "$ID" = "ubuntu" ]; then
	if grep -qE '^Suites: noble noble-updates noble-backports' /etc/apt/sources.list.d/ubuntu.sources; then
		echo "The 'backports' repository is enabled already."
	else
		echo "The 'backports' repository is not enabled, adding."
		sudo cat <<EOF >/etc/apt/sources.list.d/backports.sources
Types: deb
URIs: http://archive.ubuntu.com/ubuntu
Suites: noble noble-updates noble-backports
Components: main universe restricted multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
EOF
	fi
fi
# 2. update package manager
sudo apt update && sudo apt upgrade -y
# 3. install and run apache2
sudo apt install -y apache2
# 4. install python3
sudo apt install -y python3-{pip,venv}
# 5. install and run ssh
sudo apt install -y sshd
# minimum 10 actions in total, including installation of everything needed for other tasks

# install fish

if [ "$ID" = "debian" ]; then
	if [ "VERSION_ID" = "12" ]; then
		echo 'deb http://download.opensuse.org/repositories/shells:/fish:/release:/3/Debian_12/ /' | sudo tee /etc/apt/sources.list.d/shells:fish:release:3.list
		curl -fsSL https://download.opensuse.org/repositories/shells:fish:release:3/Debian_12/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/shells_fish_release_3.gpg >/dev/null
	elif [ "VERSION_ID" = "11" ]; then
		echo 'deb http://download.opensuse.org/repositories/shells:/fish:/release:/3/Debian_11/ /' | sudo tee /etc/apt/sources.list.d/shells:fish:release:3.list
		curl -fsSL https://download.opensuse.org/repositories/shells:fish:release:3/Debian_11/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/shells_fish_release_3.gpg >/dev/null
	elif [ "VERSION_ID" = "10" ]; then
		echo 'deb http://download.opensuse.org/repositories/shells:/fish:/release:/3/Debian_10/ /' | sudo tee /etc/apt/sources.list.d/shells:fish:release:3.list
		curl -fsSL https://download.opensuse.org/repositories/shells:fish:release:3/Debian_10/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/shells_fish_release_3.gpg >/dev/null
	fi
	sudo apt update
	sudo apt install -y fish
elif [ "$ID" = "ubuntu" ]; then
	if [ "VERSION_ID" = "24.04" ]; then
		sudo apt update
		sudo apt install -y fish
	else
		sudo apt-add-repository ppa:fish-shell/release-3
		sudo apt update
		sudo apt install -y fish
	fi
elif [ "$ID" = "fedora" ]; then
	dnf check-update
	sudo dnf install -y fish

elif [ "$ID" = "opensuse" ]; then
	sudo zypper refresh
	sudo zypper install fish

elif [ "$ID_LIKE" = "arch" ]; then
	sudo pacman -Sy fish

fi

chsh -s /bin/fish

# installing other useful apps
sudo apt install -y git neovim
