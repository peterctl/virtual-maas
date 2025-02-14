sudo snap remove --purge maas maas-test-db lxd juju
find . -name '*tfstate*' -type f -delete
rm -r ~/.local/share/juju
