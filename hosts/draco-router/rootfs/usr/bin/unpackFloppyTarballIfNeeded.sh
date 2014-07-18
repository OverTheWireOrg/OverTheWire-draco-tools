#!/bin/bash

fstype=ext2
flopdev=/dev/fd0
floptarball=/root/newfloppy.tgz

# If there is a new floppy image
if [ ! -e $floptarball ];
then
    exit 0
fi

# First unmount floppy
umount $flopdev

# reformat it
dd if=/dev/zero bs=512 count=2880 of=/$flopdev
mkfs.$fstype -F $flopdev

# mount it again
mount $flopdev
mountPoint=$(mount -l | awk "\$1 == \"$flopdev\" { print \$3 }")

# unpack tarball
pushd $mountPoint
tar -xf $floptarball
popd
sync;sync;sync

# remove floppy image
rm $floptarball

exit 0
