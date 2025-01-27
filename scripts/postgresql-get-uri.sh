#!/bin/bash

username=${1:-operator}
legacy_model=$(juju status --format json | jq -r '.model.version | startswith("2")')
psql_ip=$(juju show-unit postgresql/0 | yq -r '.[].public-address')
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
