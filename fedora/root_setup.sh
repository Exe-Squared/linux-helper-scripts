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

dnf install gcc make automake autoconf gnupg git python3-devel vim shellcheck tmux ripgrep fd multitail tree jq yq rsync fzf -y
dnf install ca-certificates traceroute curl wget redis hyperfine -y
dnf install htop bat mariadb-server httpd mod_ssl golang-bin xclip trash-cli -y

systemctl enable --now httpd

info "Installing docker"
wget --quiet -O - "https://raw.githubusercontent.com/Exe-Squared/linux-helper-scripts/refs/heads/feature/alma-9-scripts/fedora/install-docker.sh" | bash

info "Installing PHP"
info "Installing REMI GPG Key"

sudo rpm --import "https://rpms.remirepo.net/fedora/42/RPM-GPG-KEY-remi"
sudo dnf clean all
sudo dnf update -y

info "Installing REMI Repository"

sudo dnf install -y "https://rpms.remirepo.net/fedora/remi-release-42.rpm"

INSTALL_VERSIONS=("7.4" "8.0" "8.1" "8.2" "8.3" "8.4")
for VERSION in "${INSTALL_VERSIONS[@]}"; do
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
    "${PHP}-php-bcmath" "${PHP}-php-imap" "${PHP}-php-imagick" "${PHP}-php-devel" "${PHP}-php-pecl-xdebug"
  wget --quiet -O - https://raw.githubusercontent.com/benmoses-dev/linux-helper-scripts/main/xdebug3.ini > "/etc/opt/remi/${PHP}/php.d/15-xdebug.ini"

  systemctl enable --now "${PHP}-php-fpm"

  # Remove /usr/bin/php if it exists and is not a symlink
  if [ -e /usr/bin/php ] && ! [ -h /usr/bin/php ]; then
    unlink /usr/bin/php
  fi

  # Remove /usr/bin/phpize if it exists and is not a symlink
  if [ -e /usr/bin/phpize ] && ! [ -h /usr/bin/phpize ]; then
    unlink /usr/bin/phpize
  fi

  # Remove /usr/bin/php-config if it exists and is not a symlink
  if [ -e /usr/bin/php-config ] && ! [ -h /usr/bin/php-config ]; then
    unlink /usr/bin/php-config
  fi

  update-alternatives --install /usr/bin/php php "/opt/remi/php${VERSION_WO_DOT}/root/usr/bin/php" "${VERSION_WO_DOT}"
  update-alternatives --install /usr/bin/phpize phpize "/opt/remi/php${VERSION_WO_DOT}/root/usr/bin/phpize" "${VERSION_WO_DOT}"
  update-alternatives --install /usr/bin/php-config php-config "/opt/remi/php${VERSION_WO_DOT}/root/usr/bin/php-config" "${VERSION_WO_DOT}"
done

if [[ -z $(command -v php) ]]; then
    error "PHP Not Installed!"
    sleep 1
fi

systemctl enable --now redis

# Install Desktop Software
info "Installing desktop software"

dnf install -y vlc gnome-tweaks i3 i3status dmenu i3lock xbacklight feh conky libreoffice \
	libreoffice-help-en filezilla virt-manager picom kitty scrot pass

info "Disable SELinux"
setenforce 0
sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config

success "System Software Install Finished!"
sleep 1
