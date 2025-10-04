#!/usr/bin/env bash

set -e

# Colours
COLOR_RED=$(tput setaf 1)
COLOR_GREEN=$(tput setaf 2)
COLOR_YELLOW=$(tput setaf 3)
COLOR_BLUE=$(tput setaf 4)
COLOR_RESET=$(tput sgr0)
SILENT=false

print() {
	if [[ "${SILENT}" == false ]]; then
		echo -e "$@"
	fi
}

error() {
    print "${COLOR_RED}"
    print "${1}"
    print "${COLOR_RESET}"
}

info() {
    print "${COLOR_YELLOW}"
    print "${1}"
    print "${COLOR_RESET}"
}

warning() {
    print "${COLOR_BLUE}"
    print "${1}"
    print "${COLOR_RESET}"
}

success() {
    print "${COLOR_GREEN}"
    print "${1}"
    print "${COLOR_RESET}"
}

if [[ "$EUID" -ne 0 ]]; then
	print "${COLOR_RED}"
	print "Please run this script as root!"
	print "${COLOR_RESET}"
    sleep 1
	exit 0
fi

info "Updating System..."
sleep 1

dnf update -y

info "Installing System Software"
sleep 2

dnf install epel-release -y
dnf copr enable tkbcopr/fd -y  # Enable fd package from Fedora cobr
dnf install gnupg git python3-devel vim shellcheck tmux ripgrep fd multitail tree jq rsync fzf -y
dnf install ca-certificates traceroute curl wget -y
dnf install htop bat mariadb-server nginx -y

## Install xclip from source
info "Installing xclip from source"

dnf install libXmu-devel libX11-devel -y

git clone https://github.com/astrand/xclip.git
cd xclip
./bootstrap
./configure
make
make install
cd
rm -rf xclip

## Install trash-cli from source
cd
git clone https://github.com/andreafrancia/trash-cli.git
cd trash-cli
python3 setup.py install
cd
rm -rf trash-cli

systemctl enable --now nginx
sed -i 's/#server_tokens/server_tokens/g' /etc/nginx/nginx.conf
systemctl restart nginx

info "Installing docker"
wget --quiet -O - "https://raw.githubusercontent.com/Exe-Squared/linux-helper-scripts/refs/heads/feature/alma-9-scripts/alma/install-docker.sh" | bash

info "Installing PHP"
wget --quiet -O - "https://raw.githubusercontent.com/Exe-Squared/linux-helper-scripts/refs/heads/feature/alma-9-scripts/alma/scripts/install-php.sh" > "/home/$SUDO_USER/.local/bin/install-php"
chown "$SUDO_USER:$SUDO_USER" "/home/$SUDO_USER/.local/bin/install-php"
chmod +x "/home/$SUDO_USER/.local/bin/install-php"

INSTALL_VERSIONS=("7.4" "8.0" "8.1" "8.2" "8.3" "8.4")
for VERSION in ${INSTALL_VERSIONS[@]}; do
  info "Installing PHP ${VERSION}"
  sudo -u "$SUDO_USER" bash -c "~/.local/bin/install-php $VERSION"
done

if [[ -z $(command -v php) ]]; then
    error "PHP Not Installed!"
    sleep 1
fi

success "System Software Install Finished!"
sleep 1
