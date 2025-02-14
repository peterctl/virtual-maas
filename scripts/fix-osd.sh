#!/bin/bash

juju exec -a ceph-osd 'ceph-volume lvm activate --all'
