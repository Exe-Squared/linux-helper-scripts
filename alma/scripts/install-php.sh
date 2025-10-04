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

info "Installing REMI GPG Key"

sudo rpm --import "https://rpms.remirepo.net/enterprise/10/RPM-GPG-KEY-remi"
sudo dnf clean all
sudo dnf update -y

info "Installing REMI Repository"

sudo dnf install -y "https://rpms.remirepo.net/enterprise/remi-release-10.rpm"

info "Installing PHP and PHP-FPM"

sudo dnf install -y "$PHP" "${PHP}-php-fpm"

MODULES=("pdo" "pdo_mysql" "redis" "exif" "curl" "pcntl" "posix" "zip" "json" "common" "mbstring" "xml" "mysqlnd" "gd" "mysqli" "bcmath" "imap" "imagick")
for MODULE in ${MODULES[@]}; do
  info "Installing PHP ${MODULE}"
  sudo dnf install "${PHP}-php-${MODULE}" -y
done

sudo systemctl enable --now "${PHP}-php-fpm"

cat <<EOL >> "${HOME}/.bash_aliases"
alias php${PHP_VERSION}='sudo update-alternatives --set php /opt/remi/php${PHP_VERSION}/root/usr/bin/ph'
EOL