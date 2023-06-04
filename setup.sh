#!/bin/bash

# https://github.com/pi-hole/docker-pi-hole/blob/master/README.md

# Based on the original pi-hole setup
timezone=$(timedatectl show --property=Timezone --value)
local_ip=$(hostname -I | grep -oP '^\S+')

PIHOLE_BASE="${PIHOLE_BASE:-$(pwd)}"
[[ -d "$PIHOLE_BASE" ]] || mkdir -p "$PIHOLE_BASE" || { echo "Couldn't create storage directory: $PIHOLE_BASE"; exit 1; }

# Note: FTLCONF_LOCAL_IPV4 should be replaced with your external ip.
# Note: port 6969 is adjusted due to other services often running on port 80/8080
docker run -d \
    --name pihole \
    -p 53:53/tcp -p 53:53/udp \
    -p 6969:80 \
    -e TZ="$timezone" \
    -v "${PIHOLE_BASE}/etc-pihole:/etc/pihole" \
    -v "${PIHOLE_BASE}/etc-dnsmasq.d:/etc/dnsmasq.d" \
    --dns=1.1.1.1 \
    --restart=unless-stopped \
    --hostname pi.hole \
    -e VIRTUAL_HOST="pi.hole" \
    -e PROXY_LOCATION="pi.hole" \
    -e FTLCONF_LOCAL_IPV4="10.0.1.38" \
    pihole/pihole:latest

printf 'Starting up pihole container\n'
container_id=$(docker ps -q -n 1)
printf 'Enter the password you want to use for pi-hole: '
read password
docker exec -it $container_id $password -a -p $password -a -p
echo -e "\n password: $password for pi-hole running at: http://$local_ip:6969/admin"
exit 0