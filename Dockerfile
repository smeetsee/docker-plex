# Actual container
FROM plexinc/pms-docker

# Based on https://pterodactyl.io/community/config/eggs/creating_a_custom_image.html#creating-the-dockerfile
RUN adduser --disabled-password --home /home/container container

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