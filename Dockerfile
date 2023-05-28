# Actual container
FROM base-${TARGETARCH}

# Based on https://pterodactyl.io/community/config/eggs/creating_a_custom_image.html#creating-the-dockerfile
RUN useradd -o -u 0 --home-dir /home/container -g plex container

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

# Re-configure permissions on services
RUN chown -R container:plex /etc/services.d/plex && chmod -R 0644 /etc/services.d/plex

# Plex runs on port 32400
EXPOSE 32400/tcp

# Set user, based on https://stackoverflow.com/a/49955098/2378368
USER container
ENV  USER=container HOME=/home/container

# Based on https://github.com/just-containers/s6-overlay#read-only-root-filesystem
ENV S6_READ_ONLY_ROOT=1

# Define executable with parameters
WORKDIR /home/container
COPY ./entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/bin/sh", "-c", "mkdir -p /tmp/run && mkdir -p /home/container/config && mkdir -p /home/container/transcode && /init"]
# CMD ["/bin/bash", "/entrypoint.sh"]