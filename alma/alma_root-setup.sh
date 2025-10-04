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
dnf install gcc make automake autoconf gnupg git python3-devel vim shellcheck tmux ripgrep fd multitail tree jq rsync fzf -y
dnf install ca-certificates traceroute curl wget -y
dnf install htop bat mariadb-server nginx -y

## Install xclip from source
info "Installing xclip from source"

dnf install libXmu-devel libX11-devel -y

cd
if [[ ! -d ./xclip ]]; then
  git clone https://github.com/astrand/xclip.git
fi
cd xclip
./bootstrap
./configure
make
make install
cd
rm -rf xclip

## Install trash-cli from source
cd
if [[ ! -d ./trash-cli ]]; then
  git clone https://github.com/andreafrancia/trash-cli.git
fi
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

info "Installing REMI GPG Key"

sudo rpm --import "https://rpms.remirepo.net/enterprise/10/RPM-GPG-KEY-remi"
sudo dnf clean all
sudo dnf update -y

info "Installing REMI Repository"

sudo dnf install -y "https://rpms.remirepo.net/enterprise/remi-release-10.rpm"

INSTALL_VERSIONS=("7.4" "8.0" "8.1" "8.2" "8.3" "8.4")
for VERSION in ${INSTALL_VERSIONS[@]}; do
  VERSION_WO_DOT=${VERSION//.}
    PHP="php${VERSION_WO_DOT}"

  if [[ -d "/opt/remi/${PHP}" ]]; then
    warning "PHP ${VERSION} already installed. Skipping..."
    continue
  fi

  info "Installing PHP ${VERSION}"
  info "Installing PHP and PHP-FPM"

  dnf install -y "$PHP" "${PHP}-php-fpm"

  info "Installing PHP Modules"

  dnf install -y \
    "${PHP}-php-pdo" "${PHP}-php-pdo_mysql" "${PHP}-php-redis" "${PHP}-php-exif" "${PHP}-php-curl" \
    "${PHP}-php-pcntl" "${PHP}-php-posix" "${PHP}-php-zip" "${PHP}-php-json" "${PHP}-php-common" \
    "${PHP}-php-mbstring" "${PHP}-php-xml" "${PHP}-php-mysqlnd" "${PHP}-php-gd" "${PHP}-php-mysqli" \
    "${PHP}-php-bcmath" "${PHP}-php-imap" "${PHP}-php-imagick" "${PHP}-php-devel"
  wget --quiet -O - https://raw.githubusercontent.com/benmoses-dev/linux-helper-scripts/main/xdebug3.ini > "/etc/opt/remi/${PHP}/php.d/xdebug.ini"

  systemctl enable --now "${PHP}-php-fpm"

  cat <<EOL >> "/home/${SUDO_USER}/.bash_aliases"
  alias php${VERSION_WO_DOT}='sudo update-alternatives --set php /opt/remi/${PHP}/root/usr/bin/php && sudo update-alternatives --set phpize /opt/remi/${PHP}/root/usr/bin/phpize && sudo update-alternatives --set php-config /opt/remi/${PHP}/root/usr/bin/php-config && echo "PHP Updated to ${VERSION}"'
EOL

  update-alternatives --set php "/opt/remi/php${VERSION_WO_DOT}/root/usr/bin/php"
done

if [[ -z $(command -v php) ]]; then
    error "PHP Not Installed!"
    sleep 1
fi

success "System Software Install Finished!"
sleep 1
