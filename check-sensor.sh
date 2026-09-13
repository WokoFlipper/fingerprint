#!/bin/bash
# Identify the fingerprint sensor and tell whether its firmware is flashable.
# No root needed for detection (fwupd steps need root/polkit separately).
set -u

echo "==> USB fingerprint devices:"
FOUND="$(lsusb 2>/dev/null | grep -iE '27c6|06cb|04f3|138a|10c4|1c7a|147e|finger|validity|egis|elan|synap|goodix|fpc ' || true)"
if [[ -z $FOUND ]]; then
    echo "    none found on USB. If your reader is SPI/I2C (some ELAN), check libfprint elanspi support."
else
    echo "$FOUND" | sed 's/^/    /'
fi
echo

classify() {
    local vid="$1" pid="$2"
    case "$vid" in
        27c6)
            echo "    vendor: Goodix (MOC/TLS family)"
            echo "    firmware: YES via fwupd (goodix-moc plugin) IF the vendor published it on LVFS;"
            echo "              run: fwupdmgr refresh --force && fwupdmgr get-devices"
            if [[ "$pid" == "5110" ]]; then
                echo "    note: 27c6:5110 TLS (Huawei/Honor MateBook/MagicBook) — works with stock"
                echo "          libfprint goodixmoc (no flash needed). Community TLS forks historically"
                echo "          required a one-time flash with the goodix-fp-dump tool."
            fi
            ;;
        06cb)
            echo "    vendor: Synaptics (Prometheus family, common on ThinkPads)"
            echo "    firmware: YES via fwupd (synaptics-prometheus plugin) if LVFS carries it;"
            echo "              run: fwupdmgr refresh --force && fwupdmgr get-devices"
            ;;
        04f3)
            echo "    vendor: ELAN (elan / elanmoc drivers in libfprint)"
            echo "    firmware: NO fwupd path — works out of the box or not at all; keep libfprint fresh."
            ;;
        138a)
            echo "    vendor: Validity/Synaptics (legacy)"
            echo "    firmware: NO — most 138a:00xx are unsupported by libfprint, no flash path."
            ;;
        10c4)
            echo "    vendor: FPC (fpcmoc driver in libfprint)"
            echo "    firmware: NO fwupd path."
            ;;
        1c7a)
            echo "    vendor: EgisTec (egismoc driver in libfprint)"
            echo "    firmware: NO fwupd path."
            ;;
        *) echo "    vendor: unknown ($vid:$pid) — check libfprint supported-devices list." ;;
    esac
}

if [[ -n $FOUND ]]; then
    echo "==> classification:"
    echo "$FOUND" | grep -oE 'ID [0-9a-fA-F]{4}:[0-9a-fA-F]{4}' | awk '{print $2}' | while IFS=: read -r vid pid; do
        echo "  * $vid:$pid"
        classify "$vid" "$pid"
    done
fi

echo
echo "==> fprintd view:"
if command -v fprintd-list >/dev/null 2>&1; then
    fprintd-list "$USER" 2>&1 | head -5 | sed 's/^/    /'
else
    echo "    fprintd not installed"
fi
