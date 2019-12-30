#!/usr/bin/with-contenv bash

TIMESTAMP_FORMAT='%a %b %d %T %Y'
log() {
  echo "$(date +"${TIMESTAMP_FORMAT}") [tunnel-down] $*"
}

# If sabnzbd-pre-stop.sh exists, run it
if [ -x /config/sabnzbd-pre-stop.sh ]
then
   log "Executing /config/sabnzbd-pre-stop.sh"
   /config/sabnzbd-pre-stop.sh "$@"
   log "/config/sabnzbd-pre-stop.sh returned $?"
fi

log "STOPPING SABNZBD"
s6-svc -d /var/run/s6/services/sabnzbd

# If sabnzbd-post-stop.sh exists, run it
if [ -x /config/sabnzbd-post-stop.sh ]
then
   log "Executing /config/sabnzbd-post-stop.sh"
   /config/sabnzbd-post-stop.sh "$@"
   log "/config/sabnzbd-post-stop.sh returned $?"
fi
