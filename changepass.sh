#!/bin/bash
read -p "Enter new password: " password
container_id=$(docker ps -q -n 1)
docker exec -it $container_id pihole -a -p "$password"