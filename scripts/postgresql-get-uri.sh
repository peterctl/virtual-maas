#!/bin/bash

username=${1:-operator}
app_name=${2:-postgresql}
juju_status=$(juju status --format json)
legacy_model=$(echo "$juju_status" | jq -r '.model.version | startswith("2")')
psql_leader=$(
  echo "$juju_status" |
    jq -r --arg app $app_name '
      .applications[$app].units |
        to_entries[] |
        select(.value.leader) |
        .key
      '
)
psql_ip=$(juju show-unit $psql_leader | yq -r '.[].public-address')
psql_pass=$(
  if $legacy_model; then
    juju run-action --format yaml --wait postgresql/leader get-password username=$username |
      yq -r '.[].results.password'
  else
    juju run --format yaml postgresql/leader get-password username=$username |
      yq -r '.[].results.password'
  fi
)
psql_uri="postgresql://$username:$psql_pass@$psql_ip:5432"
echo $psql_uri
