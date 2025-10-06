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

if [[ $# -ne 1 ]]; then
    error "A PHP Version must be passed as a parameter"
    error "E.g. $0 8.1"
    exit 1
fi

if ! [[ $1 =~ ^[0-9]+\.[0-9]+$ ]]; then
    error "The PHP version must be in the format number.number"
    error "E.g. 8.1, 10.0, 0.2"
    error "Got: $1"
    exit 2
fi

PHP_VERSION="${1//.}"
PHP="php$PHP_VERSION"

if [[ -d "/opt/remi/${PHP}" ]]; then
  info "PHP $1 already installed"
  exit 0
fi

info "Installing PHP and PHP-FPM"

sudo dnf install -y "$PHP" "${PHP}-php-fpm"

info "Installing PHP Modules"

sudo dnf install -y \
  "${PHP}-php-pdo" "${PHP}-php-pdo_mysql" "${PHP}-php-redis" "${PHP}-php-exif" "${PHP}-php-curl" \
  "${PHP}-php-pcntl" "${PHP}-php-posix" "${PHP}-php-zip" "${PHP}-php-json" "${PHP}-php-common" \
  "${PHP}-php-mbstring" "${PHP}-php-xml" "${PHP}-php-mysqlnd" "${PHP}-php-gd" "${PHP}-php-mysqli" \
  "${PHP}-php-bcmath" "${PHP}-php-imap" "${PHP}-php-imagick" "${PHP}-php-devel" "${PHP}-php-pecl-xdebug"

sudo wget --quiet -O - https://raw.githubusercontent.com/benmoses-dev/linux-helper-scripts/main/xdebug3.ini > "/etc/opt/remi/${PHP}/php.d/15-xdebug.ini"

sudo systemctl enable --now "${PHP}-php-fpm"

cat <<EOL >> "${HOME}/.bash_aliases"
alias php${VERSION_WO_DOT}='sudo update-alternatives --set php /opt/remi/${PHP}/root/usr/bin/php && sudo update-alternatives --set phpize /opt/remi/${PHP}/root/usr/bin/phpize && sudo update-alternatives --set php-config /opt/remi/${PHP}/root/usr/bin/php-config && echo "PHP Updated to ${VERSION}"'
EOL

# Remove /usr/bin/php if it exists and is not a symlink
if [ -e /usr/bin/php ] && ! [ -h /usr/bin/php ]; then
  sudo unlink /usr/bin/php
fi

# Remove /usr/bin/phpize if it exists and is not a symlink
if [ -e /usr/bin/phpize ] && ! [ -h /usr/bin/phpize ]; then
  sudo unlink /usr/bin/phpize
fi

# Remove /usr/bin/php-config if it exists and is not a symlink
if [ -e /usr/bin/php-config ] && ! [ -h /usr/bin/php-config ]; then
  sudo unlink /usr/bin/php-config
fi

sudo update-alternatives --install /usr/bin/php php "/opt/remi/php${VERSION_WO_DOT}/root/usr/bin/php" "${VERSION_WO_DOT}"
sudo update-alternatives --install /usr/bin/phpize phpize "/opt/remi/php${VERSION_WO_DOT}/root/usr/bin/phpize" "${VERSION_WO_DOT}"
sudo update-alternatives --install /usr/bin/php-config php-config "/opt/remi/php${VERSION_WO_DOT}/root/usr/bin/php-config" "${VERSION_WO_DOT}"