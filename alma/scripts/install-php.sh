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

sudo dnf install "${PHP}-php-pdo_mysql" "${PHP}-php-redis" "${PHP}-php-exif" "${PHP}-php-curl" \
  "${PHP}-php-pcntl" "${PHP}-php-posix" "${PHP}-php-zip" "${PHP}-php-json" "${PHP}-php-common" \
  "${PHP}-php-mbstring" "${PHP}-php-xml" "${PHP}-php-mysqlnd" "${PHP}-php-gd" "${PHP}-php-mysqli" \
  "${PHP}-php-bcmath" "${PHP}-php-imap" "${PHP}-php-imagick"

sudo wget --quiet -O - https://raw.githubusercontent.com/benmoses-dev/linux-helper-scripts/main/xdebug3.ini > "/etc/opt/remi/${PHP}/php.d/xdebug.ini"

sudo systemctl enable --now "${PHP}-php-fpm"

cat <<EOL >> "${HOME}/.bash_aliases"
alias php${PHP_VERSION}='sudo update-alternatives --set php /opt/remi/php${PHP_VERSION}/root/usr/bin/php'
EOL

sudo update-alternatives --set php "/opt/remi/php${PHP_VERSION}/root/usr/bin/php"