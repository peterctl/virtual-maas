#!/bin/bash

# LXD cannot be restarted while MAAS is running because the networks will fail to enable.
# This is because LXD will try to launch dnsmasq to set the bridge gateway address, but
# it will complain that MAAS is already listening on the DHCP port. To work around this,
# stop MAAS, then restart LXD so that it can launch the networks correctly, then start
# MAAS again.
sudo snap stop maas
sudo snap restart lxd
sudo snap start maas
