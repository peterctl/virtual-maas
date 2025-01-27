#!/bin/bash

legacy_model=$(juju status --format json | jq -r '.model.version | startswith("2")')
if $legacy_model; then
  juju run-action --format yaml --wait vault/leader get-root-ca |
    yq -r '.[].results.output'
else
  juju run --format yaml vault/leader get-root-ca |
    yq -r '.[].results.output'
fi
