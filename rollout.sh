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

# install fish
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
	sudo apt install -y fish
elif [ "$ID" = "ubuntu" ]; then
	if [ "$VERSION_ID" = "24.04" ]; then
		echo Ubuntu Noble already contains fresh-enough Fish Shell
	else
		echo Outdated Ubuntu detected, adding Fish ppa
		sudo apt-add-repository ppa:fish-shell/release-3
	fi
fi

# 3. install and run apache2
# 4. install python3
# 5. install and run ssh
if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
	# 2. update package manager
	sudo apt update && sudo apt upgrade -y
	sudo apt install -y apache2 python3-{pip,venv} ssh neovim git fish zsh
elif [ "$ID" = "fedora" ]; then
	# exact packages are not tested! specified here as conditional example! everything was tested on ubuntu VM only!
	dnf check-update
	sudo dnf install -y apache2 python3 neovim git fish openssh-server zsh && sudo systemctl enable --now sshd
elif [ "$ID" = "opensuse" ]; then
	# exact packages are not tested! specified here as conditional example! everything was tested on ubuntu VM only!
	sudo zypper refresh
	sudo zypper install apache2 python neovim git fish openssh zsh && sudo systemctl enable --now sshd.service
elif [ "$ID_LIKE" = "arch" ]; then
	# exact packages are not tested! specified here as conditional example! everything was tested on ubuntu VM only!
	sudo pacman -Syu apache python neovim git fish openssh zsh && sudo systemctl enable --now sshd
fi

# generate key if not exists
if [ ! -f ~/.ssh/id_ed25519.pub ]; then
	ssh-keygen -t ed25519
fi
sudo sed -i "s|^\($USER.*\)/bin/bash|\1/bin/zsh|" /etc/passwd # changing default shell to fish for current user

# minimum 10 actions in total, including installation of everything needed for other tasks
