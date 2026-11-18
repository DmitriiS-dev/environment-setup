#!/usr/bin/env bash

install_prerequisites() {
    # Avoid a partial upgrade when refreshing Arch package databases.
    run_root pacman -Syu --needed --noconfirm curl wget ca-certificates
}

install_system_packages() {
    run_root pacman -Syu --needed --noconfirm "${COMMON_PACKAGES[@]}" \
        eza base-devel python python-pip go nodejs npm
}

install_firewall() {
    run_root pacman -S --needed --noconfirm ufw
    export FIREWALL=ufw
}
