#!/bin/bash
set -ouex pipefail

# use flatpak of firefox instead
dnf5 remove -y firefox

# example using copr
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# dnf5 -y copr disable ublue-os/staging

# enable podman.socket
systemctl enable podman.socket
