#!/bin/bash
# Fedora one-shot: deps + enroll + PAM via authselect.
# Run in a terminal (you will touch the sensor + type sudo password).
set -u

sudo dnf install -y fprintd fprintd-pam || exit 1

echo "==> enroll (touch the sensor when asked)"
fprintd-enroll -u "$USER" || exit 1

echo "==> PAM (authselect fingerprint feature)"
sudo authselect enable-feature with-fingerprint || exit 1
sudo authselect apply-changes || exit 1

echo "Check: authselect current | grep -i finger"
echo "Verify in a NEW terminal (keep this one open): sudo -v"
echo "Rollback: sudo authselect disable-feature with-fingerprint && sudo authselect apply-changes"
