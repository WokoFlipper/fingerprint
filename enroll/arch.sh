#!/bin/bash
# Arch Linux one-shot: deps + enroll + PAM.
# Run in a terminal (you will touch the sensor + type sudo password).
set -u
D="$(cd "$(dirname "$0")" && pwd)"

sudo pacman -S --needed fprintd libfprint python-gobject gtk3 || exit 1

echo "==> enroll (touch the sensor when asked)"
fprintd-enroll -u "$USER" || exit 1

echo "==> PAM (system-auth + sudo, with backups)"
"$D/../setup-pam.sh" || exit 1

echo "Verify in a NEW terminal (keep this one open): sudo -v"
