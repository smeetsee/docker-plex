# Actual container
FROM plexinc/pms-docker:main

# Based on https://pterodactyl.io/community/config/eggs/creating_a_custom_image.html#creating-the-dockerfile
RUN adduser --disabled-password --home /home/container container

RUN ln -s /config /home/container/config
RUN ln -s /transcode /home/container/transcode
RUN ln -s /data /home/container/data

# Plex runs on port 32400
EXPOSE 32400/tcp

# Set user, based on https://stackoverflow.com/a/49955098/2378368
USER container
ENV  USER=container HOME=/home/container

# Define executable with parameters
# ENTRYPOINT [ "/usr/local/bin/xteve","-config=/home/container/.xteve/" ]
WORKDIR /home/container
COPY ./entrypoint.sh /entrypoint.sh
CMD ["/bin/bash", "/entrypoint.sh"]