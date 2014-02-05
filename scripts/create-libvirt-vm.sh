#!/bin/bash

NAME=$name$
target=$targetdir$

bootstrap=$(readlink -f scripts/__bootstrap-from-makevm.sh)

virsh destroy $NAME
virsh undefine $NAME
rm -rf $target/$NAME
ubuntu-vm-builder kvm precise --dest $target/$NAME --arch i386 --hostname $NAME --mem 256 \
 	--user $user$ --pass $password$  --bridge $bridge$ \
	--components main,universe,restricted --execscript="$bootstrap" \
	--libvirt qemu:///system

chown -R root.root $target/$NAME

virsh start $NAME
