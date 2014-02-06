#!/bin/bash


dir=$(readlink -f "$1")
outfile=$(readlink -f "$2")
tmpfile=$(mktemp)

fstype=ext2

dd if=/dev/zero bs=512 count=2880 of="$tmpfile"
mkfs.$fstype -F "$tmpfile"

tmpdir=$(mktemp -d)

mount -o loop -t $fstype "$tmpfile" $tmpdir

echo "Copying to $tmpdir/"
cd "$dir"
find . | cpio -vpmd "$tmpdir"

cd /
sync;sync;sync
umount $tmpdir

rmdir $tmpdir
mv $tmpfile $outfile


