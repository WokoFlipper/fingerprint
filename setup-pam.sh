#!/bin/bash
# Enable fingerprint auth in PAM (needs root). Run in a terminal.
# Backs every touched file up as <file>.bak.<timestamp> first.
# Uses "sufficient" (never "required") so the password fallback always works —
# a bad fingerprint can never lock you out.
set -u

LINE="auth sufficient pam_fprintd.so"
FILES="/etc/pam.d/system-auth /etc/pam.d/sudo"

for f in $FILES; do
    [ -f "$f" ] || { echo "skip (missing): $f"; continue; }
    if grep -q 'pam_fprintd\.so' "$f"; then
        echo "already present: $f"
        continue
    fi
    bak="$f.bak.$(date +%F-%T)"
    echo "==> $f (backup: $bak)"
    sudo cp -p "$f" "$bak" || exit 1
    # insert after the #%PAM-1.0 header line
    sudo awk -v line="$LINE" 'NR==1{print; print line; next}1' "$f" > /tmp/pam-new \
        && sudo install -m 644 /tmp/pam-new "$f" && rm -f /tmp/pam-new
done

echo "Verify in a NEW terminal (keep this one open): sudo -v"
echo "Rollback: sudo cp -p <file>.bak.<timestamp> <file>"
