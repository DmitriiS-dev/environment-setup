#!/usr/bin/env bash

PKG_MGR=dnf
if ! has dnf; then
    PKG_MGR=yum
fi

install_prerequisites() {
    run_root "$PKG_MGR" install -y curl wget ca-certificates
}

install_system_packages() {
    if ! run_root "$PKG_MGR" install -y epel-release; then
        log_warn "EPEL is unavailable; continuing with the configured repositories."
    fi
    run_root "$PKG_MGR" upgrade -y
    run_root "$PKG_MGR" install -y "${COMMON_PACKAGES[@]}" \
        gcc gcc-c++ make python3 python3-pip golang
    if ! has node || ! has npm; then
        run_root "$PKG_MGR" install -y nodejs npm
    fi
    if ! has eza && ! run_root "$PKG_MGR" install -y eza; then
        log_warn "eza is unavailable from the package manager; trying a release binary."
    fi
}

install_firewall() {
    if run_root "$PKG_MGR" install -y ufw; then
        FIREWALL=ufw
    else
        log_warn "UFW is unavailable; using firewalld."
        run_root "$PKG_MGR" install -y firewalld
        FIREWALL=firewalld
    fi
    export FIREWALL
}
