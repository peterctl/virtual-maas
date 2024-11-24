#!/bin/bash

ADMIN_USER="admin"
ADMIN_PASS="password"

haproxy_ip=$(juju show-unit haproxy/0 | yq -r '.[].public-address')
juju ssh landscape-server/leader sudo /opt/canonical/landscape/bootstrap-account \
  --root_url "https://$haproxy_ip/" \
  --admin_name $ADMIN_USER \
  --admin_email "${ADMIN_USER}@landscape" \
  --admin_password $ADMIN_PASS

psql_ip=$(juju show-unit postgresql/0 | yq -r '.[].public-address')
operator_pass=$(
  juju run-action --wait postgresql/leader get-password username=operator |
    yq -r '.[].results.password'
)
psql_uri="postgresql://operator:$operator_pass@$psql_ip:5432"
python landscape_get_api_credentials.py $psql_uri
