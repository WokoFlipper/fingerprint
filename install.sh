#!/bin/bash
# Install Fingerprint manager (TUI + GTK GUI) for the current user.
# Run: ./install.sh   (no root needed; PAM setup is a separate step)
set -u
D="$(cd "$(dirname "$0")" && pwd)"

echo "==> checking dependencies"
missing=0
for bin in fprintd-enroll fprintd-list fprintd-verify fprintd-delete python3; do
    command -v "$bin" >/dev/null 2>&1 || { echo "    MISSING: $bin"; missing=1; }
done
python3 -c "import gi" 2>/dev/null || { echo "    MISSING: python-gobject (gi)"; missing=1; }
if (( missing )); then
    echo "Install deps first, e.g. Arch: sudo pacman -S fprintd libfprint python-gobject gtk3"
    echo "Debian/Ubuntu: sudo apt install fprintd libpam-fprintd python3-gi gir1.2-gtk-3.0"
    exit 1
fi

echo "==> binaries -> ~/.local/bin"
mkdir -p ~/.local/bin
install -m 755 "$D/fngrmngr" ~/.local/bin/fngrmngr
install -m 755 "$D/fngrmngr-gui" ~/.local/bin/fngrmngr-gui

echo "==> desktop entry + icons"
mkdir -p ~/.local/share/applications
install -m 644 "$D/fingerprint.desktop" ~/.local/share/applications/fingerprint.desktop
mkdir -p ~/.local/share/icons/hicolor/scalable/apps ~/.local/share/icons/hicolor/256x256/apps
install -m 644 "$D/icons/fingerprint.svg" ~/.local/share/icons/hicolor/scalable/apps/fingerprint.svg
install -m 644 "$D/icons/fingerprint.png" ~/.local/share/icons/hicolor/256x256/apps/fingerprint.png
gtk-update-icon-cache -q -t -f ~/.local/share/icons/hicolor 2>/dev/null || true
update-desktop-database ~/.local/share/applications 2>/dev/null || true

echo "Done. Launch 'Fingerprint' from the menu, or run: fngrmngr-gui  /  fngrmngr"
echo "Next: enroll a finger, then enable it in PAM (see README, setup-pam.sh)."
