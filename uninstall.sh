#!/bin/bash
# Remove the Fingerprint manager (user install). Enrolled prints and PAM
# lines are left untouched — see README → Rollback for those.
# Run: ./uninstall.sh   (no root needed)
set -u

rm -f ~/.local/bin/fngrmngr ~/.local/bin/fngrmngr-gui
rm -f ~/.local/share/applications/fingerprint.desktop
rm -f ~/.local/share/icons/hicolor/scalable/apps/fingerprint.svg \
      ~/.local/share/icons/hicolor/256x256/apps/fingerprint.png
gtk-update-icon-cache -q -t -f ~/.local/share/icons/hicolor 2>/dev/null || true
update-desktop-database ~/.local/share/applications 2>/dev/null || true

echo "Removed. Enrolled fingerprints: fprintd-delete -u \"\$USER\" -f <name>."
echo "PAM lines: restore from /etc/pam.d/*.bak.<timestamp> (see README)."
