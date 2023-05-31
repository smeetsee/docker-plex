#!/usr/bin/with-contenv bash

# Based on https://github.com/plexinc/pms-docker/blob/dad8fe0493434bbd18d799a04a9666ea22735b46/root/etc/cont-init.d/40-plex-first-run

# If acme.sh is already installed, we do not need to install it again.
if [ -e /home/container/.acme.sh ]; then
  exit 0
fi

curl https://get.acme.sh | sh -s -- nocron