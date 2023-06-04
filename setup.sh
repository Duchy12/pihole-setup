#!/bin/bash

# https://github.com/pi-hole/docker-pi-hole/blob/master/README.md

# Based on the original pi-hole setup
timezone=$(timedatectl show --property=Timezone --value)
local_ip=$(hostname -I | grep -oP '^\S+')

PIHOLE_BASE="${PIHOLE_BASE:-$(pwd)}"
[[ -d "$PIHOLE_BASE" ]] || mkdir -p "$PIHOLE_BASE" || { echo "Couldn't create storage directory: $PIHOLE_BASE"; exit 1; }

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
    -e FTLCONF_LOCAL_IPV4="$local_ip" \
    pihole/pihole:latest

printf 'Starting up pihole container\n'

# Wait for the container to start running
while true; do
    container_id=$(docker ps -q -n 1)
    container_status=$(docker inspect -f '{{.State.Status}}' "$container_id")
    if [ "$container_status" == "running" ]; then
        break
    fi
    sleep 1
done

docker exec "$container_id" pihole -a -p "pihole" &
wait $!

echo -e "\npassword: pihole for pi-hole running at: http://$local_ip:6969/admin"
exit 0