#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y inkscape kitty krita neovim
dnf5 remove -y konsole kwrite vim

# install flatpaks
project_root=$(/)
flatpak_dir_shortname="default_flatpaks"

# temp space
TEMP_FLATPAK_INSTALL_DIR=$(mktemp -d -p "${project_root}" flatpak.XXX)

# list of refs
FLATPAK_REFS_DIR=${project_root}/${flatpak_dir_shortname}
FLATPAK_REFS_DIR_LIST=$(tr '\n' ' ' < "${FLATPAK_REFS_DIR}/flatpaks")

# install script
cat << EOF > "${TEMP_FLATPAK_INSTALL_DIR}/script.sh"
cat /temp_flatpak_install_dir/script.sh
mkdir -p /flatpak/flatpak /flatpak/triggers
mkdir /var/tmp || true
chmod -R 1777 /var/tmp
flatpak config --system --set languages "*"
flatpak remote-add --system flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install --system -y ${FLATPAK_REFS_DIR_LIST}
ostree refs --repo=\${FLATPAK_SYSTEM_DIR}/repo | grep '^deploy/' | grep -v 'org\.freedesktop\.Platform\.openh264' | sed 's/^deploy\///g' > /output/flatpaks_with_deps
EOF

workspace=${project_root}
if [[ -f /.dockerenv || -f /run/.containerenv ]]; then
    FLATPAK_REFS_DIR=${LOCAL_WORKSPACE_FOLDER}/${flatpak_dir_shortname}
    TEMP_FLATPAK_INSTALL_DIR="${LOCAL_WORKSPACE_FOLDER}/$(echo "${TEMP_FLATPAK_INSTALL_DIR}" | rev | cut -d / -f 1 | rev)"
    workspace=${LOCAL_WORKSPACE_FOLDER}
fi

# flatpak deps list
if [[ ! -f ${project_root}/${flatpak_dir_shortname}/flatpaks_with_deps ]]; then
    "${container_mgr}" run --rm --privileged \
        --entrypoint bash \
        -e FLATPAK_SYSTEM_DIR=/flatpak/flatpak \
        -e FLATPAK_TRIGGERSDIR=/flatpak/triggers \
        --volume "${FLATPAK_REFS_DIR}":/output \
        --volume "${TEMP_FLATPAK_INSTALL_DIR}":/temp_flatpak_install_dir \
        "ghcr.io/ublue-os/${base_image}-main:${version}" /temp_flatpak_install_dir/script.sh
fi

# remove temp dir
if [[ -f /.dockerenv ]]; then
    TEMP_FLATPAK_INSTALL_DIR=${project_root}/$(echo "${TEMP_FLATPAK_INSTALL_DIR}" | rev | cut -d / -f 1 | rev)
fi
rm -rf "${TEMP_FLATPAK_INSTALL_DIR}"

if [[ ${container_mgr} =~ "podman" ]]; then
    api_socket=/run/podman/podman.sock
elif [[ ${container_mgr} =~ "docker" ]]; then
    api_socket=/var/run/docker.sock
fi

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket
