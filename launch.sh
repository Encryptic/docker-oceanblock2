#!/bin/bash

set -x

# FTB OceanBlock 2
# Details from:
# https://www.feed-the-beast.com/modpacks/128-ftb-oceanblock-2?tab=versions

cd /modpack
cp -R . /data
cd /data

if ! [[ "$EULA" = "false" ]]; then
    echo "eula=true" > eula.txt
else
    echo "You must accept the EULA to install."
    exit 99
fi

touch /data/server.properties

if [[ -n "$JVM_OPTS" ]]; then
    sed -i '/-Xm[s,x]/d' user_jvm_args.txt
    for j in ${JVM_OPTS}; do sed -i '$a\'$j'' user_jvm_args.txt; done
fi
if [[ -n "$MOTD" ]]; then
    sed -i "s/^motd=.*/motd=$MOTD/" /data/server.properties
fi
if [[ -n "$ENABLE_WHITELIST" ]]; then
    sed -i "s/white-list=.*/white-list=$ENABLE_WHITELIST/" /data/server.properties
fi
if [[ -n "$ALLOW_FLIGHT" ]]; then
    sed -i "s/allow-flight=.*/allow-flight=$ALLOW_FLIGHT/" /data/server.properties
fi
if [[ -n "$MAX_PLAYERS" ]]; then
    sed -i "s/max-players=.*/max-players=$MAX_PLAYERS/" /data/server.properties
fi
if [[ -n "$ONLINE_MODE" ]]; then
    sed -i "s/online-mode=.*/online-mode=$ONLINE_MODE/" /data/server.properties
fi

# Initialize whitelist.json if not present
if [[ ! -f whitelist.json ]]; then
    echo "[]" > whitelist.json
fi

IFS=',' read -ra USERS <<< "$WHITELIST_USERS"
for raw_username in "${USERS[@]}"; do
    username=$(echo "$raw_username" | xargs)

    if [[ -z "$username" ]] || ! [[ "$username" =~ ^[a-zA-Z0-9_]{3,16}$ ]]; then
        echo "Whitelist: Invalid or empty username: '$username'. Skipping..."
        continue
    fi

    UUID=$(curl -s "https://playerdb.co/api/player/minecraft/$username" | jq -r '.data.player.id')
    if [[ "$UUID" != "null" ]]; then
        if jq -e ".[] | select(.uuid == \"$UUID\" and .name == \"$username\")" whitelist.json > /dev/null; then
            echo "Whitelist: $username ($UUID) is already whitelisted. Skipping..."
        else
            echo "Whitelist: Adding $username ($UUID) to whitelist."
            jq ". += [{\"uuid\": \"$UUID\", \"name\": \"$username\"}]" whitelist.json > tmp.json && mv tmp.json whitelist.json
        fi
    else
        echo "Whitelist: Failed to fetch UUID for $username."
    fi
done

# Initialize ops.json if not present
if [[ ! -f ops.json ]]; then
    echo "[]" > ops.json
fi

IFS=',' read -ra OPS <<< "$OP_USERS"
for raw_username in "${OPS[@]}"; do
    username=$(echo "$raw_username" | xargs)

    if [[ -z "$username" ]] || ! [[ "$username" =~ ^[a-zA-Z0-9_]{3,16}$ ]]; then
        echo "Ops: Invalid or empty username: '$username'. Skipping..."
        continue
    fi

    UUID=$(curl -s "https://playerdb.co/api/player/minecraft/$username" | jq -r '.data.player.id')
    if [[ "$UUID" != "null" ]]; then
        if jq -e ".[] | select(.uuid == \"$UUID\" and .name == \"$username\")" ops.json > /dev/null; then
            echo "Ops: $username ($UUID) is already an operator. Skipping..."
        else
            echo "Ops: Adding $username ($UUID) as operator."
            jq ". += [{\"uuid\": \"$UUID\", \"name\": \"$username\", \"level\": 4, \"bypassesPlayerLimit\": false}]" ops.json > tmp.json && mv tmp.json ops.json
        fi
    else
        echo "Ops: Failed to fetch UUID for $username."
    fi
done

sed -i 's/server-port.*/server-port=25565/g' server.properties
./run.sh
