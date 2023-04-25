#!/bin/sh

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

# Setup
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-{cisco-openh264,modular,updates-modular}.repo

# Fetch necessary rpms
wget -P /tmp/rpms \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${RELEASE}.noarch.rpm \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${RELEASE}.noarch.rpm
# Install rpms
rpm-ostree install /tmp/rpms/*.rpm # Get older kernel for NVidia

# Fetch necessary repos
wget -P /tmp/repos \
    https://download.opensuse.org/repositories/home:lamlng/Fedora_37/home:lamlng.repo
cp -r /tmp/repos/. /etc/yum.repos.d/

# Modify base image
source /var/cache/akmods/nvidia-vars
REMOVED_PACKAGES=(
    gnome-software gnome-software-rpm-ostree gnome-classic-session gnome-tour gnome-disk-utility
    open-vm-tools-desktop open-vm-tools qemu-guest-agent spice-vdagent spice-webdavd virtualbox-guest-additions
    gnome-shell-extension-apps-menu gnome-shell-extension-window-list gnome-shell-extension-background-logo gnome-shell-extension-launch-new-instance gnome-shell-extension-places-menu
    firefox firefox-langpacks yelp toolbox
)
INSTALLED_PACKAGES=(
    xorg-x11-drv-nvidia-{,power}*
    /var/cache/akmods/${NVIDIA_PACKAGE_NAME}/kmod-${NVIDIA_PACKAGE_NAME}-${KERNEL_VERSION}-${NVIDIA_AKMOD_VERSION}.fc${RELEASE}.rpm
    gnome-tweaks zsh distrobox ibus-bamboo
)
rpm-ostree override remove ${REMOVED_PACKAGES[@]}
rpm-ostree install ${INSTALLED_PACKAGES[@]}

# alternatives cannot create symlinks on its own during a container build
ln -s /usr/bin/ld.bfd /etc/alternatives/ld && ln -s /etc/alternatives/ld /usr/bin/ld

# Disable RPMFusion repos
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/rpmfusion-{,non}free{,-updates}.repo
