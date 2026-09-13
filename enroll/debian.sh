#!/bin/bash
# Debian/Ubuntu one-shot: deps + enroll + PAM via pam-auth-update.
# Run in a terminal (you will touch the sensor + type sudo password).
set -u

sudo apt update && sudo apt install -y fprintd libpam-fprintd || exit 1

echo "==> enroll (touch the sensor when asked)"
fprintd-enroll -u "$USER" || exit 1

echo "==> PAM (fprintd profile, non-interactive)"
sudo pam-auth-update --package --enable fprintd || exit 1

echo "Check: grep -r pam_fprintd /etc/pam.d/common-auth"
echo "Verify in a NEW terminal (keep this one open): sudo -v"
echo "Rollback: sudo pam-auth-update --package --remove fprintd"
