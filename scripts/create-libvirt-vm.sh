#!/bin/bash

NAME=badidea
target=/data/OTW/

bootstrap=$(readlink -f scripts/__bootstrap-from-makevm.sh)

virsh destroy $NAME
virsh undefine $NAME
rm -rf $target/$NAME
ubuntu-vm-builder kvm precise --dest $target/$NAME --arch i386 --hostname $NAME --mem 256 \
 	--user otw --pass otw  --bridge br-vlan24 \
	--components main,universe,restricted --execscript="$bootstrap" \
	--libvirt qemu:///system

#--ip 172.27.100.10 --mask 255.255.255.248 \
#--net 172.27.100.8 --bcast 172.27.100.15 --gw 172.27.100.9 --domain labs.overthewire.org \

chown -R root.root $target/$NAME

virsh start $NAME
