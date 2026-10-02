# brave-autowipe configuration
# copy to /data/adb/brave-autowipe.conf and edit

# com.brave.browser         - Brave stable
# com.brave.browser_beta    - Brave Beta
# com.brave.browser_nightly - Brave Nightly
PKG="com.brave.browser"

# seconds between checks (higher = less battery)
CHECK_INTERVAL=5

LOG="/data/local/tmp/brave-wipe.log"

# rotate log above this size in bytes
MAX_LOG_SIZE=51200

# 1 = log launches too, 0 = log wipes only
VERBOSE=0