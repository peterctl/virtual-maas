#!/bin/bash

DATE_FORMAT="%F %H:%M:%S.%N"
DEFAULT_TIMEOUT=60s

ENDPOINT=$1
TIMEOUT=${2:-$DEFAULT_TIMEOUT}

if [ -z "$ENDPOINT" ]; then
  echo "ERROR: missing endpoint"
  echo "usage: $0 <endpoint> [<timeout>]"
  exit 1
fi

function _date() {
  date "+$DATE_FORMAT"
}

function log() {
  echo "[$(_date)]" $@
}

function curl-loop() {
  endpoint="$1"
  while true; do
    status=$(curl -sI -o /dev/null -w '%{http_code}' $endpoint)
    log "curl $endpoint status: $status"
    if [[ "$status" == "200" ]]; then
      break
    fi
    sleep 3
  done
}

export DATE_FORMAT
export -f _date
export -f log
export -f curl-loop

timeout --foreground $TIMEOUT bash -c "curl-loop $ENDPOINT"
