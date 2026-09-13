# Security notes — Fingerprint manager

## Password handling

- `fngrmngr-gui` asks for the sudo password through its own GTK dialog and
  pipes it to `sudo -S` **in memory only** (stdin, never written to disk,
  never logged). The password object is dropped after use.
- Enroll/delete run as `sudo -u $USER fprintd-*`: privileged only to reach
  the fprintd D-Bus device node, scoped to the invoking user (`-u $USER`).
- The TUI (`fngrmngr`) uses plain `sudo` (terminal prompt), same as any
  admin CLI.

## PAM design (anti-lockout)

- `setup-pam.sh` backs up every file (`*.bak.<timestamp>`) before touching it.
- It inserts `auth sufficient pam_fprintd.so` — **sufficient, never required**
  — so the password fallback always works. A failed/foreign finger can never
  lock you out.
- Rollback is one `cp` per file (see README).

## What never happens

- No network access, no telemetry, no exfiltration.
- Fingerprint templates never leave the sensor/`/var/lib/fprintd` store;
  these tools only call the stock `fprintd-*` clients.
- Nothing is autostarted, no daemons, no setuid binaries.
