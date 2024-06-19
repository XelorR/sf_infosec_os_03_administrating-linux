#!/bin/bash

. /etc/os-release

# check backports
if [[ "$ID" = "ubuntu" && "$VERSION_ID" = "22.04" ]]; then
	if grep -q '^deb .*jammy-backports' /etc/apt/sources.list; then
		echo backports is enabled already
	else
		sudo echo 'deb http://ru.archive.ubuntu.com/ubuntu/ jammy-backports main restricted universe multiverse' >>/etc/apt/sources.list
	fi
else
	echo "In 'backports adding' context, only Ubuntu Jammy (22.04) supported."
fi

# update and install
sudo apt update && sudo apt upgrade -y
sudo apt install -y ssh apache2 python3-{pip,venv} zsh rsync fzf ripgrep tmux

# gen key and enable ssh
if [ ! -f $HOME/.ssh/id_ed25519.pub ]; then
	ssh-keygen -t ed25519 -N ''
fi
#sudo systemctl enable --now sshd
sudo systemctl restart sshd

# additional 5 things
# 1. install/reinstall latest NeoVim version
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
mkdir -p $HOME/.opt $HOME/.local/bin
rm -rf $HOME/.opt/nvim-linux64
tar -C $HOME/.opt -xzf nvim-linux64.tar.gz
rm -rf nvim-linux64.tar.gz
rm -rf $HOME/.local/bin/nvim
ln -s $HOME/.opt/nvim-linux64/bin/nvim $HOME/.local/bin/nvim

# 2. install/reinstall lf file manager
url="https://github.com/gokcehan/lf/releases/latest/download/lf-linux-amd64.tar.gz"
archiveName="$(echo $url | cut -d'/' -f9)"
mkdir -p "$HOME/.local/bin"
rm -rf "$HOME/.local/bin/lf"
wget $url
tar xf $archiveName -C "$HOME/.local/bin/"
rm -rf $archiveName

# 3. set zsh as default shell for current user
sudo sed -i "s|^\($USER.*\)/bin/bash|\1/bin/zsh|" /etc/passwd

# 4. install GUI and enable XRDP
sudo apt install -y xfce4 xrdp
echo xfce4-session >~/.xsession

# 5. create .zshrc
cat <<'EOF' >$HOME/.zshrc
export PATH="$HOME/.local/bin:$PATH"

alias l='ls -1A'
alias ll='ls -lh'
alias la='ll -A'

if command -v nvim &>/dev/null; then
	export VISUAL=nvim
	alias vi='nvim --clean'
fi

export EDITOR=vi
if command -v fzf &>/dev/null; then
	alias vf='vi $(fzf)'
fi

if command -v rsync &>/dev/null; then
	alias cpv='rsync -ah --info=progress2'
fi

mkcd() {
  mkdir $1 && cd $1
}

mkscript() {
  touch $1 && chmod +x $1 && $VISUAL $1
}

tm() {
	if [ $# -eq 0 ]; then
		tmux a || tmux
	else
		tmux a -t $1 || tmux new -s $1
	fi
}
alias tml='tmux list-sessions'

if command -v lf &>/dev/null; then
	lf() {
		# $(command) is needed in case $(lfcd) is aliased to $(lf)
		cd "$(command lf -print-last-dir "$@")"
	}
fi
EOF
