#!/bin/sh

# Drop any in-memory wireless state left by the previous image.
if [ -x /sbin/wifi ]; then
    /sbin/wifi down >/dev/null 2>&1 || true
fi

# no-WiFi images may be flashed over a WiFi image with sysupgrade keeping
# /etc/config/wireless. Remove radios and any interfaces configured on them.
if [ -f /etc/config/wireless ]; then
    rm -f /etc/config/wireless
fi

/etc/init.d/network restart >/dev/null 2>&1 || true

exit 0
