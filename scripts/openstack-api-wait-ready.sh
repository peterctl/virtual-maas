#!/bin/bash

function usage() {
  echo "usage: $0 <app>" >&2
}

app="${1}"
if [[ -z "$app" ]]; then
  usage
  exit 1
fi

while true; do
  status=$(juju status --format json)
  all_units=$(
    echo "$status" |
      jq -r --arg app "$app" '
          .applications[$app].units | keys[]
        ' |
      wc -l
  )
  ready_units=$(
    echo "$status" |
      jq -r --arg app "$app" '
          .applications[$app].units | to_entries[] |
            select(
              .value["workload-status"].current=="active" and
              .value["juju-status"].current == "idle"
            ) |
            .key
        ' |
      wc -l
  )
  if [[ "$all_units" == "$ready_units" ]]; then
    break
  fi
  sleep 5
done
