# Fingerprint — fingerprint manager for Huawei/Honor laptops

TUI (`fngrmngr`) + GTK GUI (`fngrmngr-gui`) for enrolling, verifying and
deleting fingerprints via `fprintd`, with per-service PAM toggles
(sudo, login, lock screen…). Written for Huawei/Honor laptops, whose
fingerprint sensor is the same across models (see Step 0).

## Step 0. Sensor: identify it, flash firmware if needed

Huawei/Honor AMD laptops (MateBook D14/D15, Honor MagicBook 14/15/Pro and
siblings) ship the same sensor:

```
$ lsusb | grep -i finger
Bus 001 Device 005: ID 27c6:5110 Shenzhen Goodix Technology Co.,Ltd. ...
```

`27c6:5110` = Goodix TLS sensor, handled by libfprint's `goodixmoc` driver
(libfprint ≥ 1.94). If `fprintd-list` reports *no devices found*, the sensor
usually needs its firmware from LVFS first:

```bash
sudo pacman -S fwupd            # or: sudo apt install fwupd
fwupdmgr refresh --force
fwupdmgr get-devices | grep -iA5 -i goodix
fwupdmgr update                 # applies Goodix firmware if offered
reboot
```

After reboot `fprintd-list "$USER"` should show the device
(`Goodix TLS Fingerprint Sensor`).

## Step 1. Stack

```bash
# Arch
sudo pacman -S fprintd libfprint python-gobject gtk3
# Debian/Ubuntu
sudo apt install fprintd libpam-fprintd python3-gi gir1.2-gtk-3.0
```

Check: `fprintd-list "$USER"` → device line, no fingerprints yet.

## Step 2. Install these tools (no root)

```bash
./install.sh
```

Installs `fngrmngr` (terminal UI) and `fngrmngr-gui` (GTK app, menu name
“Fingerprint”) to `~/.local/bin`, plus the desktop entry and icons.

## Step 3. Enroll fingers

GUI: open **Fingerprint**, pick a numbered finger (1–10), confirm with your
**sudo password** (adding/deleting never uses the fingerprint itself, so a
half-enrolled finger can't lock you out). Or terminal:

```bash
fprintd-enroll -u "$USER" -f right-index-finger
fprintd-list "$USER"      # verify it is stored
fprintd-verify            # test it
```

## Step 4. Enable in PAM (needs root, in a terminal)

```bash
./setup-pam.sh
```

Backs up every touched file (`*.bak.<timestamp>`) and adds
`auth sufficient pam_fprintd.so` to `system-auth` and `sudo`.
`sufficient` (never `required`) keeps the password fallback, so a failed
finger can never lock you out. Then verify **in a new terminal**
(keep the old one open): `sudo -v` → touch the sensor.

The GUI can also toggle PAM per service
(system-auth, sudo, su, hyprlock, screen lock) with green/yellow buttons.

## Step 5. Rollback

```bash
sudo cp -p /etc/pam.d/system-auth.bak.<timestamp> /etc/pam.d/system-auth
sudo cp -p /etc/pam.d/sudo.bak.<timestamp> /etc/pam.d/sudo
fprintd-delete -u "$USER" -f right-index-finger   # per finger, or delete all in GUI
```

## Troubleshooting

- `Already claimed by another process` on verify → a stale `fprintd-verify`
  holds the sensor; kill it and retry (the GUI does this automatically).
- Fingerprint prompt never appears under `sudo` → check the `pam_fprintd.so`
  line is present and *above* `pam_unix.so`; keep a root terminal open while
  experimenting.
- Sensor missing after kernel update → re-run `fwupdmgr get-devices`; if gone,
  reinstall `libfprint`/`fprintd` and reboot.

## Files

| File | Purpose |
|---|---|
| `fngrmngr` | Terminal UI (bash, pseudo-graphics) |
| `fngrmngr-gui` | GTK3 GUI (Python): fingers 1–10, verify, PAM toggles |
| `fingerprint.desktop` | Menu entry |
| `icons/` | App icons (SVG + 256px PNG) |
| `install.sh` | User install (deps check + files) |
| `setup-pam.sh` | PAM enable with backups (root) |

## License

MIT — see [LICENSE](LICENSE).
