#!/bin/bash

NAME=$name$
target=$targetdir$

bootstrap=$(readlink -f scripts/__bootstrap-from-makevm.sh)

virsh destroy $NAME
virsh undefine $NAME
rm -rf $target/$NAME
mkdir -p $targetdir$/$NAME
ubuntu-vm-builder kvm precise --dest $target/$NAME --arch i386 --hostname $NAME --mem $memory$ \
 	--user $user$ --pass $password$  --bridge $bridge$ \
	--components main,universe,restricted --execscript="$bootstrap" \
	--libvirt qemu:///system

chown -R root.root $target/$NAME

if $isrouter$;
then
    # add second network card
    virsh attach-interface $NAME bridge $bridge2$ --persistent

    # add floppy drive
    # This is ugly as fuck, I blame libvirt
    floppyimg="$floppyimage$"
    EDITOR='sed -i "s:</devices>:<disk type=\"file\" device=\"floppy\"><source file=\"'$floppyimg'\"/><target dev=\"fda\"/></disk>\n&:"' virsh edit $NAME
fi

virsh start $NAME
