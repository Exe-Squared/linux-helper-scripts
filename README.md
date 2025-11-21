# linux-helper-scripts
### Collection of helper scripts for Linux and FreeBSD
### These scripts are not thoroughly tested and may not work

# Usage
## Desktop Ubuntu (24.04)
```
wget --quiet -O - https://raw.githubusercontent.com/Exe-Squared/linux-helper-scripts/main/ubuntu/ubuntu_2404_desktop_root-setup.sh | sudo bash
```
```
wget --quiet -O - https://raw.githubusercontent.com/Exe-Squared/linux-helper-scripts/main/ubuntu/ubuntu_2204_user-setup.sh | bash
```
## Windows Subsystem for Linux (Ubuntu 24.04, with systemd enabled) or Ubuntu Server (24.04)
```
wget --quiet -O - https://raw.githubusercontent.com/Exe-Squared/linux-helper-scripts/main/ubuntu/ubuntu_2404_root-setup.sh | sudo bash
```
```
wget --quiet -O - https://raw.githubusercontent.com/Exe-Squared/linux-helper-scripts/main/ubuntu/ubuntu_2204_user-setup.sh | bash
```

## Almalinux 10

```shell
wget --quiet -O - https://raw.githubusercontent.com/Exe-Squared/linux-helper-scripts/main/alma/alma_root_setup.sh | sudo bash
```

```shell
wget --quiet -O - https://raw.githubusercontent.com/Exe-Squared/linux-helper-scripts/main/alma/alma_user_setup.sh | bash
```

Reboot to have changes apply properly
```shell
reboot
```

## Fedora 42

```shell
wget --quiet -O - https://raw.githubusercontent.com/Exe-Squared/linux-helper-scripts/main/fedora/root_setup.sh | sudo bash
```

```shell
wget --quiet -O - https://raw.githubusercontent.com/Exe-Squared/linux-helper-scripts/main/fedora/user_setup.sh | bash
```

Reboot to have changes apply properly
```shell
reboot
```

## Fedora 43 - WSL

```shell
wget --quiet -O - https://raw.githubusercontent.com/Exe-Squared/linux-helper-scripts/refs/heads/hotfix/fedora43_wsl/fedora/root_setup-wsl.sh | sudo bash
```

```shell
wget --quiet -O - https://raw.githubusercontent.com/Exe-Squared/linux-helper-scripts/main/fedora/user_setup.sh | bash
```

Reboot to have changes apply properly
```shell
reboot
```