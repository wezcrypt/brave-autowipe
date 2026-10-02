# brave-autowipe

Automatically clears all Brave browser data on Android when the app closes.

A background service script for rooted devices. Watches the Brave process and
runs `pm clear` the moment it exits, wiping cookies, history, cache, sessions,
and site data.

> **Warning**
> This performs a full `pm clear` on Brave. Bookmarks, saved passwords, and
> signed-in accounts are deleted along with browsing data. Export your
> bookmarks before installing.
>
> If you only want browsing data cleared, Brave's built-in
> **Settings â†’ Privacy â†’ Clear browsing data on exit** does that without root
> and keeps your bookmarks.

## Requirements

- Rooted Android device
- Magisk (uses `/data/adb/service.d`)
- Brave browser installed

## Install

### Via ADB

```
adb push . /data/local/tmp/brave-autowipe/
adb shell
su
cd /data/local/tmp/brave-autowipe
sh install.sh
reboot
```

### On device (Termux)

```
git clone https://github.com/wezcrypt/brave-autowipe
cd brave-autowipe
su -c "sh install.sh"
```

## Configuration

Edit `/data/adb/brave-autowipe.conf`:

| Option | Default | Description |
|---|---|---|
| `PKG` | `com.brave.browser` | Package to watch |
| `CHECK_INTERVAL` | `5` | Seconds between process checks |
| `LOG` | `/data/local/tmp/brave-wipe.log` | Log file path |
| `MAX_LOG_SIZE` | `51200` | Rotate log above this size in bytes |
| `VERBOSE` | `0` | Set to `1` to log launches as well as wipes |

Changes take effect after reboot.

## Testing without reboot

```
su -c "sh /data/adb/service.d/brave-wipe.sh &"
```

Open Brave, visit a site, then swipe it away from recents. Wait ten seconds
and reopen â€” it should start fresh.

Check the log:

```
cat /data/local/tmp/brave-wipe.log
```

## Uninstall

```
su -c "sh uninstall.sh"
```

Or manually:

```
su
rm /data/adb/service.d/brave-wipe.sh
reboot
```

## What gets deleted

`pm clear` wipes the entire app data directory. That means everything:

- Browsing history and cookies
- Saved passwords
- Bookmarks
- Signed-in accounts
- All browser settings and preferences
- Extensions and their data

Export your bookmarks before installing.

## Troubleshooting

### Script doesn't run after reboot

Some Magisk setups prefer a different directory. Try:

```
su
mv /data/adb/service.d/brave-wipe.sh /data/adb/post-fs-data.d/
chmod 755 /data/adb/post-fs-data.d/brave-wipe.sh
reboot
```

### Data isn't being cleared

Brave may stay alive in the background. Check:

```
su -c "pidof com.brave.browser"
```

If it returns a PID after you've closed the app, restrict background activity:
**Settings â†’ Apps â†’ Brave â†’ Battery â†’ Restricted**

### "Permission denied" during install

You're not root. Run `su` first â€” the prompt should change from `$` to `#`.

### Script exits immediately

Line endings. If the file was edited on Windows:

```
su -c "sed -i 's/\r$//' /data/adb/service.d/brave-wipe.sh"
```

## Battery impact

The script polls every five seconds. On a modern device this is negligible,
but if you want to reduce it further, raise `CHECK_INTERVAL` to `15` or `30`.
The tradeoff is a longer delay between closing Brave and the wipe.

## Notes

This works with any Android app, not just Brave. Change `PKG` in the config to
watch something else.

## License

MIT â€” see [LICENSE](LICENSE).