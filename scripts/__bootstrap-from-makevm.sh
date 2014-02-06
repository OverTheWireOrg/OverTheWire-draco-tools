#!/bin/bash

echo "Executing bootstrap-trampoline.sh with args: $@" > /tmp/log

rootfs=$1

# copy files into rootfs
mkdir -p $rootfs/root/$name$
cp -r . $rootfs/root/$name$

# chroot into rootfs and run install scripts
chroot $rootfs bash -c "cd /root/$name$ && ./scripts/__install.sh"

