# Actual container
FROM base-${TARGETARCH}

# Based on https://pterodactyl.io/community/config/eggs/creating_a_custom_image.html#creating-the-dockerfile
RUN addgroup -g 2001 -S plex && adduser --disabled-password -u 1001 --home /home/container -S plex container

# Symlink needed directories into /home/container
RUN ln -s /config /home/container/config && ln -s /transcode /home/container/transcode && ln -s /data /home/container/data

# Plex runs on port 32400
EXPOSE 32400/tcp

# Set user, based on https://stackoverflow.com/a/49955098/2378368
# USER container
ENV  USER=container HOME=/home/container

# Define executable with parameters
WORKDIR /home/container
COPY ./entrypoint.sh /entrypoint.sh
CMD ["/bin/bash", "/entrypoint.sh"]