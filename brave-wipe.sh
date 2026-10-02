#!/system/bin/sh
#
# brave-autowipe — clears Brave browser data when the app closes
#

CONFIG="/data/adb/brave-autowipe.conf"

PKG="com.brave.browser"
CHECK_INTERVAL=5
LOG="/data/local/tmp/brave-wipe.log"
MAX_LOG_SIZE=51200
VERBOSE=0

[ -f "$CONFIG" ] && . "$CONFIG"

log() {
    [ "$VERBOSE" = "0" ] && [ "$2" = "debug" ] && return
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$$] $1" >> "$LOG"
}

rotate_log() {
    [ -f "$LOG" ] || return
    size=$(stat -c %s "$LOG" 2>/dev/null || echo 0)
    if [ "$size" -gt "$MAX_LOG_SIZE" ]; then
        mv "$LOG" "$LOG.old"
        log "log rotated"
    fi
}

verify_package() {
    if ! pm list packages 2>/dev/null | grep -q "^package:$PKG$"; then
        log "ERROR: package $PKG not installed - exiting"
        exit 1
    fi
}

cleanup() {
    log "received signal - shutting down"
    exit 0
}

trap cleanup TERM INT

until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 5
done

sleep 10
verify_package

log "started, watching $PKG (interval: ${CHECK_INTERVAL}s)"
was_running=0
wipe_count=0

while true; do
    if pidof "$PKG" > /dev/null 2>&1; then
        if [ "$was_running" = "0" ]; then
            log "launched" debug
        fi
        was_running=1
    else
        if [ "$was_running" = "1" ]; then
            if pm clear "$PKG" > /dev/null 2>&1; then
                wipe_count=$((wipe_count + 1))
                log "closed - data cleared (total: $wipe_count)"
            else
                log "ERROR: pm clear failed for $PKG"
            fi
            was_running=0
            rotate_log
        fi
    fi
    sleep "$CHECK_INTERVAL"
done