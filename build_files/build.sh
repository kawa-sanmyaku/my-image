#!/bin/bash
set -ouex pipefail

# use flatpak of firefox instead, remove other packages
dnf5 remove -y firefox konsole

# install packages
dnf5 install -y kitty papirus-icon-theme

# example using copr
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# dnf5 -y copr disable ublue-os/staging

# enable podman.socket
systemctl enable podman.socket
