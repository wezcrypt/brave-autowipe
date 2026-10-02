#!/system/bin/sh

SERVICE_DIR="/data/adb/service.d"
SCRIPT_NAME="brave-wipe.sh"
CONFIG_PATH="/data/adb/brave-autowipe.conf"
SRC_DIR="$(dirname "$0")"

say() { echo "[*] $1"; }
err() { echo "[!] $1" >&2; }

if [ "$(id -u)" != "0" ]; then
    err "must run as root. use: su -c 'sh install.sh'"
    exit 1
fi

if [ ! -d "/data/adb" ]; then
    err "/data/adb not found - is Magisk installed?"
    exit 1
fi

if [ ! -f "$SRC_DIR/$SCRIPT_NAME" ]; then
    err "$SCRIPT_NAME not found in $SRC_DIR"
    exit 1
fi

mkdir -p "$SERVICE_DIR"

say "installing script..."
cp "$SRC_DIR/$SCRIPT_NAME" "$SERVICE_DIR/$SCRIPT_NAME"
sed -i 's/\r$//' "$SERVICE_DIR/$SCRIPT_NAME"
chmod 755 "$SERVICE_DIR/$SCRIPT_NAME"

if [ ! -f "$CONFIG_PATH" ]; then
    say "installing default config..."
    cp "$SRC_DIR/config.example.sh" "$CONFIG_PATH"
    chmod 644 "$CONFIG_PATH"
else
    say "config already exists - keeping it"
fi

say "verifying..."
if [ -x "$SERVICE_DIR/$SCRIPT_NAME" ]; then
    say "installed successfully"
    echo ""
    echo "    config: $CONFIG_PATH"
    echo "    script: $SERVICE_DIR/$SCRIPT_NAME"
    echo ""
    echo "    reboot to activate, or test now with:"
    echo "    sh $SERVICE_DIR/$SCRIPT_NAME &"
else
    err "installation failed"
    exit 1
fi