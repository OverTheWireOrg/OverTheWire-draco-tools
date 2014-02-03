#!/bin/bash

echo "Executing bootstrap-trampoline.sh with args: $@" > /tmp/log

rootfs=$1

# copy files into rootfs
mkdir -p $rootfs/root/badidea
cp -r . $rootfs/root/badidea

# chroot into rootfs and run install scripts
chroot $rootfs bash -c "cd /root/badidea && ./__install.sh"

