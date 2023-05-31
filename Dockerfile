# Actual container
FROM base-${TARGETARCH}

ENV PLEX_UID=1001
ENV PLEX_GID=2001
# ENV CHANGE_CONFIG_DIR_OWNERSHIP=false

# Based on https://pterodactyl.io/community/config/eggs/creating_a_custom_image.html#creating-the-dockerfile
RUN addgroup --gid 997 container && adduser --disabled-password -u 997 --home /home/container --system --ingroup container container

# Fix users/groups; based on https://stackoverflow.com/a/29540180
RUN head -n 65 /etc/cont-init.d/40-plex-first-run | bash

# Symlink needed directories into /home/container
RUN rmdir /config /transcode && ln -s /home/container/config / && ln -s /home/container/transcode / && ln -s /home/container/content /

# Link /run to be stored in /tmp/run
RUN mkdir -p /tmp/run && unlink /var/run && ln -s /tmp/run /var/run

# Store firstRunComplete in persistent location
RUN sed -ie 's;/.firstRunComplete;/home/container/.firstRunComplete;g' /etc/cont-init.d/40-plex-first-run

# Fix issue with path/symlink
RUN sed -ie 's;$(dirname "${prefFile}");$(dirname "$(realpath -m "${prefFile}")");g' /etc/cont-init.d/40-plex-first-run

# Remove undesirable init scripts
RUN rm /etc/cont-init.d/45-plex-hw-transcode-and-connected-tuner /etc/cont-init.d/50-plex-update /etc/cont-init.d/40-plex-first-rune

# Modify run-script to remove s6-setuidgid
RUN sed -ie 's;s6-setuidgid plex;;g' /etc/services.d/plex/run
RUN sed -ie 's;kill -15;kill -n 15;g' /etc/services.d/plex/finish
RUN sed -ie 's;kill -9;kill -n 9;g' /etc/services.d/plex/finish

# Re-configure permissions on services
RUN chown -R plex:plex /etc/services.d/plex && chmod -R 0755 /etc/services.d/plex
# Re-configure permissions on init scripts
RUN chown -R plex:plex /etc/cont-init.d && chmod -R 0744 /etc/cont-init.d

# Give permissions on hardware transcode directories
RUN /bin/bash -c 'export CURRENT_GROUP=$(getent group 44 | awk -F: "{print \$1}") && if [ -z "${CURRENT_GROUP}" ] ; then groupadd -g 44 video1 && usermod -a -G video1 plex; fi'
RUN /bin/bash -c 'export CURRENT_GROUP=$(getent group 109 | awk -F: "{print \$1}") && if [ -z "${CURRENT_GROUP}" ] ; then groupadd -g 109 render1 && usermod -a -G render1 plex; fi'
RUN /bin/bash -c 'export CURRENT_GROUP=$(getent group 110 | awk -F: "{print \$1}") && if [ -z "${CURRENT_GROUP}" ] ; then groupadd -g 110 render2 && usermod -a -G render2 plex; fi'

# Plex runs on port 32400
EXPOSE 32400/tcp

# Set user, based on https://stackoverflow.com/a/49955098/2378368
USER container
ENV  USER=container HOME=/home/container

# Based on https://github.com/just-containers/s6-overlay#read-only-root-filesystem
ENV S6_READ_ONLY_ROOT=1

# Define executable with parameters
WORKDIR /home/container

# Install acme.sh
COPY 41-install-acme-sh /etc/cont-init.d/41-install-acme-sh

COPY ./entrypoint.sh /entrypoint.sh

# Reset ENTRYPOINT to use entrypoint.sh instead. Based on https://stackoverflow.com/a/40122359/2378368
ENTRYPOINT []
# ENTRYPOINT ["/bin/sh", "-c", "mkdir -p /tmp/run && mkdir -p /home/container/config && mkdir -p /home/container/transcode && mkdir -p /home/container/content && /init"]
CMD ["/bin/bash", "/entrypoint.sh"]