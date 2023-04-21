#!/bin/sh

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

# Fetch necessary rpms
wget -P /tmp/rpms \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${RELEASE}.noarch.rpm \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${RELEASE}.noarch.rpm
# Install rpms
rpm-ostree install /tmp/rpms/*.rpm fedora-repos-archive # Get older kernel for NVidia

# Fetch necessary repos
wget -P /tmp/repos \
    https://download.opensuse.org/repositories/home:lamlng/Fedora_37/home:lamlng.repo
cp -r /tmp/repos/. /etc/yum.repos.d/

# Modify base image
REMOVED_PACKAGES=(
    gnome-software gnome-software-rpm-ostree gnome-classic-session gnome-tour
    firefox firefox-langpacks yelp toolbox
)
INSTALLED_PACKAGES=(
    akmod-nvidia xorg-x11-drv-nvidia
    gnome-tweaks zsh distrobox ibus-bamboo
)
rpm-ostree override remove ${REMOVED_PACKAGES[@]} $(printf -- "--install=%s " ${INSTALLED_PACKAGES[@]})