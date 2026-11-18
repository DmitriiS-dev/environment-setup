#!/usr/bin/env bash

log_info "Firewall"
SUDO=""
if [ "$(id -u)" -ne 0 ] && has sudo; then
    # Health checks must not prompt for credentials.
    SUDO=sudo
    if ! sudo -n true 2>/dev/null; then
        warn "Cannot inspect firewall without sudo access; rerun with privileges."
        return
    fi
fi
export SUDO

if has ufw; then
    if ! status="$(run_root ufw status verbose 2>&1)"; then
        warn "Could not read UFW status: $status"
    elif ! grep -qi 'Status: active' <<<"$status"; then
        warn "UFW is installed but inactive"
    else
        pass "UFW is active"
        if grep -qE '(22/tcp|ssh)' <<<"$status"; then
            pass "Firewall allows SSH"
        else
            fail "No SSH/22 rule found; check firewall access"
        fi
        for port in 80 443; do
            if grep -qE "(^|[[:space:]])$port(/tcp|[[:space:]])" <<<"$status"; then
                pass "Firewall allows TCP/$port"
            else
                warn "No TCP/$port rule found"
            fi
        done
    fi
elif has firewall-cmd; then
    if ! status="$(run_root firewall-cmd --state 2>&1)"; then
        warn "Could not read firewalld status: $status"
    elif [ "$status" = running ]; then
        pass "firewalld is running"
    else
        warn "firewalld is not running: $status"
    fi
else
    fail "Neither UFW nor firewalld is installed"
fi
