#!/bin/bash

function filter-status() {
  local app=${1:?'app required'}
  local status=${2:?'status required'}
  local message=${3:?'message required'}

  jq -r --arg app "$app" --arg status "$status" --arg message "$message" '
      .applications[$app].units | to_entries[] |
        select(
          (.value["workload-status"].message | startswith($message))
          and .value["workload-status"].current == $status
          and .value["juju-status"].current == "idle"
        ) |
        .key
    '
}

while true; do
  status=$(juju status --format json)
  all_units=$(
    echo "$status" |
      jq -r '.applications.vault.units | keys[]' |
      wc -l
  )
  blocked_units=$(
    echo "$status" |
      filter-status vault "blocked" "Vault needs to be initialized" |
      wc -l
  )
  if [[ "$all_units" == "$blocked_units" ]]; then
    echo ready_to_init
    break
  fi
  ready_units=$(
    echo "$status" |
      filter-status vault "active" "Unit is ready" |
      wc -l
  )
  sealed_units=$(
    echo "$status" |
      filter-status vault "blocked" "Unit is sealed" |
      wc -l
  )
  if [[ "$all_units" == "$(($ready_units + $sealed_units))" ]]; then
    echo skip_init
    break
  fi
  sleep 5
done
