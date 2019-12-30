#!/usr/bin/with-contenv bash

TIMESTAMP_FORMAT='%a %b %d %T %Y'
log() {
  echo "$(date +"${TIMESTAMP_FORMAT}") [update-port] $*"
}

# Calculate the port

IPADDRESS=$1
log "ipAddress to calculate port from $IPADDRESS"
oct3=$(echo ${IPADDRESS} | tr "." " " | awk '{ print $3 }')
oct4=$(echo ${IPADDRESS} | tr "." " " | awk '{ print $4 }')
oct3binary=$(bc <<<"obase=2;$oct3" | awk '{ len = (8 - length % 8) % 8; printf "%.*s%s\n", len, "00000000", $0}')
oct4binary=$(bc <<<"obase=2;$oct4" | awk '{ len = (8 - length % 8) % 8; printf "%.*s%s\n", len, "00000000", $0}')

sum=${oct3binary}${oct4binary}
portPartBinary=${sum:4}
portPartDecimal=$((2#$portPartBinary))
if [ ${#portPartDecimal} -ge 4 ]
	then
	new_port="1"${portPartDecimal}
else
	new_port="10"${portPartDecimal}
fi
log "Calculated port $new_port"

#
# Now, set port in Sabnzbd
#

# get current listening port

sabnzbd_peer_port=$(cat /config/sabnzbd.ini | grep port | grep -oE '[0-9]+' | head -1)
if [ "$new_port" != "sabnzbd_peer_port" ]; then
  if [ "true" = "$ENABLE_UFW" ]; then
    log "Update UFW rules before changing port in Sabnzbd"

    log "Denying access to sabnzbd_peer_port"
    ufw deny "sabnzbd_peer_port"

    log "Allowing $new_port through the firewall"
    ufw allow "$new_port"
  fi
else
    log "No action needed, port hasn't changed"
fi
