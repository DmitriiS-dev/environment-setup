#!/usr/bin/env bash

install_prerequisites() {
    run_apt_get update
    run_apt_get install -y curl wget ca-certificates
}

install_system_packages() {
    run_apt_get update
    run_apt_get upgrade -y
    run_apt_get install -y "${COMMON_PACKAGES[@]}" \
        build-essential gcc g++ make python3 python3-pip python3-venv golang-go gnupg
    if ! has node || ! has npm; then
        run_apt_get install -y nodejs npm
    fi
    if ! has eza; then
        install_eza_repository
    fi
}

install_eza_repository() {
    local key
    key="$(mktemp)"
    if ! curl -fsSL https://raw.githubusercontent.com/eza-community/eza/main/deb.asc -o "$key"; then
        rm -f "$key"
        log_warn "Could not download the eza repository key; trying a release binary."
        return
    fi
    run_root mkdir -p /etc/apt/keyrings
    if run_root gpg --batch --yes --dearmor -o /etc/apt/keyrings/gierens.gpg "$key"; then
        printf '%s\n' 'deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main' |
            run_root tee /etc/apt/sources.list.d/gierens.list >/dev/null
        run_root chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
        if ! run_apt_get update || ! run_apt_get install -y eza; then
            log_warn "Could not install eza from apt; trying a release binary."
        fi
    else
        log_warn "Could not configure the eza repository key; trying a release binary."
    fi
    rm -f "$key"
}

install_firewall() {
    run_apt_get install -y ufw
    export FIREWALL=ufw
}
