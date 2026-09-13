#!/bin/bash
# One-shot fingerprint setup: picks the right per-distro script.
# Run in a terminal: ./enroll/enroll.sh
set -u
D="$(cd "$(dirname "$0")" && pwd)"

ID=""; LIKE=""
[ -r /etc/os-release ] && { ID="$(. /etc/os-release; printf '%s' "$ID")"; LIKE="$(. /etc/os-release; printf '%s' "${ID_LIKE:-}")"; }

case "$ID $LIKE" in
    *arch*|*cachyos*|*endeavour*|*manjaro*) exec "$D/arch.sh" ;;
    *debian*|*ubuntu*|*linuxmint*|*pop*)    exec "$D/debian.sh" ;;
    *fedora*|*rhel*|*centos*|*rocky*|*alma*) exec "$D/fedora.sh" ;;
    *)
        echo "Unknown distro (ID=$ID LIKE=$LIKE)."
        echo "Install fprintd + libfprint from your repos, run:"
        echo "  fprintd-enroll -u \"\$USER\""
        echo "then enable pam_fprintd in your PAM stack (see README Step 4)."
        exit 2
        ;;
esac
