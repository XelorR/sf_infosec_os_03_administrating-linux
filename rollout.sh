#!/bin/bash

# 1. check if backports repo enabled and enable if not
if grep -q 'Suites: noble noble-updates noble-backports' /etc/apt/sources.list.d/ubuntu.sources; then
	echo "The 'release-backports' repository is enabled."
else
	echo "The 'release-backports' repository is not enabled."
	# to enable
	# add:
	#   Types: deb
	#   URIs: http://archive.ubuntu.com/ubuntu
	#   Suites: noble noble-updates noble-backports
	#   Components: main universe restricted multiverse
	#   Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
fi
# 2. update package manager
sudo apt update && sudo apt upgrade -y
# 3. install and run apache2
# 4. install python3
# 5. install and run ssh
# minimum 10 actions in total, including installation of everything needed for other tasks
