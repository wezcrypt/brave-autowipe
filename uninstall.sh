#!/system/bin/sh

SERVICE_DIR="/data/adb/service.d"
SCRIPT_NAME="brave-wipe.sh"
CONFIG_PATH="/data/adb/brave-autowipe.conf"
LOG="/data/local/tmp/brave-wipe.log"

say() { echo "[*] $1"; }
err() { echo "[!] $1" >&2; }

if [ "$(id -u)" != "0" ]; then
    err "must run as root. use: su -c 'sh uninstall.sh'"
    exit 1
fi

say "stopping running instances..."
pkill -f "$SCRIPT_NAME" 2>/dev/null

say "removing script..."
rm -f "$SERVICE_DIR/$SCRIPT_NAME"

printf "remove config file too? [y/N] "
read answer
case "$answer" in
    [Yy]*) rm -f "$CONFIG_PATH"; say "config removed" ;;
    *) say "config kept at $CONFIG_PATH" ;;
esac

printf "remove logs? [y/N] "
read answer
case "$answer" in
    [Yy]*) rm -f "$LOG" "$LOG.old"; say "logs removed" ;;
    *) say "logs kept" ;;
esac

say "uninstalled. reboot to complete."