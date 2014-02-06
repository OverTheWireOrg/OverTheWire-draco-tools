#!/bin/bash

set -e

floppy=$1
tmpdir=$(mktemp -d)

mount -o loop $floppy $tmpdir

echo
echo "Dropping you into the root of $floppy. Make the changes you want and simply log out."
echo
cd $tmpdir
bash

cd /
sync;sync;sync
umount $tmpdir

rmdir $tmpdir
