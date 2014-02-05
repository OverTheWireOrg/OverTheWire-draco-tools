#!/bin/bash

bootstrap=$(readlink -f scripts/__bootstrap-from-makevm.sh)
NAME=$name$

sudo ubuntu-vm-builder vmserver precise --hostname $NAME --dest $NAME --user $user$ --pass $password$ \
	--arch i386 --mem 256 
	--components main,universe,restricted --execscript="$bootstrap"

rm -f $NAME/*.vmx ${NAME}.ova
IMAGE="$NAME/*.vmdk"

VBoxManage createvm --name ${NAME} --ostype Ubuntu --register --basefolder ${NAME}
VBoxManage modifyvm ${NAME} --memory 256 --vram 32
VBoxManage storagectl ${NAME} --name "SATA Controller" --add sata --controller IntelAHCI
VBoxManage storageattach ${NAME} --storagectl "SATA Controller" --type hdd --port 0 --device 0 --medium ${IMAGE}
VBoxManage modifyvm ${NAME} --nic1 nat

VBoxManage export ${NAME} --manifest -o $targetdir$/${NAME}.ova
VBoxManage unregistervm ${NAME} --delete

echo "Your appliance is ready at $targetdir$/${NAME}.ova"

