psql_ip=$(juju show-unit postgresql/0 | yq -r '.[].public-address')
operator_pass=$(
  juju run-action --wait postgresql/leader get-password username=operator |
    yq -r '.[].results.password'
)
psql_uri="postgresql://operator:$operator_pass@$psql_ip:5432"
echo $psql_uri
