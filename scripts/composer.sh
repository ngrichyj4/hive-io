#! /bin/sh
# Docker composer script for Ubuntu 16.04 (Xenial)
# After running the script reboot and check whether docker is running.

curl -L https://github.com/docker/compose/releases/download/1.17.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose --version