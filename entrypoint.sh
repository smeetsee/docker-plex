#!/bin/bash
cd /home/container

# Replace Startup Variables
MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
echo ":/home/container$ ${MODIFIED_STARTUP}"

# Run the Server
mkdir -p /tmp/run && mkdir -p /home/container/config && mkdir -p /home/container/transcode && mkdir -p /home/container/content && ${MODIFIED_STARTUP}