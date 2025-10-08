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

if [[ "$EUID" -eq 0 ]]; then
  error "Don't run the user setup script as root"
  sleep 1
  exit 1;
fi

if [[ -z $(command -v curl) ]] || [[ -z $(command -v wget) ]]; then
	error "Please install curl and wget before running this script!"
    sleep 1
	exit 0
fi

if [[ -z $(command -v git) ]]; then
	error "Please install git before running this script!"
    sleep 1
	exit 0
fi

mkdir -p "${HOME}/.local/bin"
mkdir -p "${HOME}/.config"

info "Configuring bash"
sleep 2

wget -O - https://raw.githubusercontent.com/Exe-Squared/linux-helper-scripts/refs/heads/feature/alma-9-scripts/alma/files/.bash_aliases >"${HOME}/.bash_aliases"
wget -O - https://raw.githubusercontent.com/Exe-Squared/linux-helper-scripts/refs/heads/feature/alma-9-scripts/alma/files/.bash_profile >"${HOME}/.bash_profile"
wget -O - https://raw.githubusercontent.com/Exe-Squared/linux-helper-scripts/refs/heads/feature/alma-9-scripts/alma/files/.bashrc >"${HOME}/.bashrc"

info "Installing rust"
sleep 2

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# install nvm, node, and npm
wget -O - https://raw.githubusercontent.com/Exe-Squared/linux-helper-scripts/main/nvm-install.sh | bash

# install composer
wget -O - https://raw.githubusercontent.com/Exe-Squared/linux-helper-scripts/main/composer-install.sh | bash

info "Installing web server automation script"
sleep 2

wget -O - https://raw.githubusercontent.com/Exe-Squared/linux-helper-scripts/refs/heads/feature/alma-9-scripts/alma/files/setup-site >"${HOME}/.local/bin/setup-site"
chmod 755 "${HOME}/.local/bin/setup-site"

info "Configuring tmux"
sleep 2

wget -O - https://raw.githubusercontent.com/Exe-Squared/linux-helper-scripts/main/ubuntu/tmux-sessionizer >"${HOME}/.local/bin/tmux-sessionizer"
chmod 755 "${HOME}/.local/bin/tmux-sessionizer"
wget -O - https://raw.githubusercontent.com/Exe-Squared/linux-helper-scripts/main/.tmux.conf >"${HOME}/.tmux.conf"

info "Configuring vim and neovim"
sleep 2

# legacy vim config
wget -O "${HOME}/.vimrc" https://raw.githubusercontent.com/Exe-Squared/linux-helper-scripts/main/.vimrc
wget -O "${HOME}/.ideavimrc" https://raw.githubusercontent.com/Exe-Squared/linux-helper-scripts/main/.ideavimrc

# neovim setup
if [[ -n $(command -v nvim) ]]; then
	error "Neovim is already installed!"
	sleep 1
else
	if [[ ! -f "${HOME}/.local/bin/nvim" ]]; then
		wget --quiet -O "${HOME}/.local/bin/nvim" https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
		chmod u+x "${HOME}/.local/bin/nvim"
	fi
	if [[ ! -d "${HOME}/.config/nvim" ]]; then
		git clone https://github.com/benmoses-dev/my-neovim.git "${HOME}/.config/nvim"
	fi
	if [[ -n $(command -v npm) ]]; then
		npm install -g neovim
		npm install -g tree-sitter-cli
	fi

	success "Neovim installed successfully!"
	warning "Consider moving the binary to /usr/local/bin if you have root privileges..."
	sleep 2
fi

# install starship
wget -O - https://raw.githubusercontent.com/Exe-Squared/linux-helper-scripts/main/starship-install.sh | bash

# install mkcert
if [[ -z $(command -v mkcert) ]]; then
  info "Installing mkcert"

  if [[ -z $(command -v go) ]]; then
    error "Go not installed"
    exit 1
  fi

  go install filippo.io/mkcert@latest

  info "mkcert installed"
fi

# install binaries via cargo
~/.cargo/bin/cargo install --locked hyperfine
~/.cargo/bin/cargo install eza

# Install scripts
wget -O "/home/$HOME/.local/bin/compare-env" https://raw.githubusercontent.com/Exe-Squared/linux-helper-scripts/refs/heads/feature/alma-9-scripts/alma/files/compare-env.py
wget -O "/home/$HOME/.local/bin/get-image" https://raw.githubusercontent.com/Exe-Squared/linux-helper-scripts/refs/heads/feature/alma-9-scripts/alma/files/get-image

chmod +x "/home/$HOME/.local/bin/compare-env"
chmod +x "/home/$HOME/.local/bin/get-image"

success "User software installed successfully!"
sleep 1
