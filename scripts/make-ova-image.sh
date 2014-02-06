#!/bin/bash

bootstrap=$(readlink -f scripts/__bootstrap-from-makevm.sh)
NAME=$name$

sudo ubuntu-vm-builder vmserver precise --hostname $NAME --dest $NAME --user $user$ --pass $password$ \
	--arch i386 --mem $memory$ --components main,universe,restricted --execscript="$bootstrap"

rm -f $NAME/*.vmx $targetdir$/${NAME}.ova
IMAGE="$NAME/*.vmdk"

VBoxManage createvm --name ${NAME} --ostype Ubuntu --register --basefolder ${NAME}
VBoxManage modifyvm ${NAME} --memory $memory$
VBoxManage storagectl ${NAME} --name "SATA Controller" --add sata --controller IntelAHCI
VBoxManage storageattach ${NAME} --storagectl "SATA Controller" --type hdd --port 0 --device 0 --medium ${IMAGE}

if $isrouter$;
then
    VBoxManage storagectl ${NAME} --name "Floppy" --add floppy --controller I82078
    VBoxManage storageattach ${NAME} --storagectl "Floppy" --device 0 --medium emptydrive
    VBoxManage modifyvm ${NAME} --nic1 nat
    VBoxManage modifyvm ${NAME} --nic2 intnet
    VBoxManage modifyvm ${NAME} --intnet2 $bridge$

    # This should work if VBoxManage worked as advertised
    VBoxManage modifyvm ${NAME} --boot1 dvd
    VBoxManage modifyvm ${NAME} --boot2 disk
    VBoxManage modifyvm ${NAME} --boot3 none
    VBoxManage modifyvm ${NAME} --boot4 none
else
    VBoxManage modifyvm ${NAME} --nic1 intnet
    VBoxManage modifyvm ${NAME} --intnet1 $bridge$
fi

mkdir -p $targetdir$
VBoxManage export ${NAME} --manifest -o $targetdir$/${NAME}.ova
VBoxManage unregistervm ${NAME} --delete

if $isrouter$;
    # Hacky fix: remove the floppy from the OVA boot order
    echo "Fixing bootorder in generated OVA"
    mv $targetdir$/${NAME}.ova $targetdir$/${NAME}.tar
    workdir=$(mktemp -d)
    cd $workdir
    echo "... unpacking OVA"
    tar -xf $targetdir$/${NAME}.tar

    echo "... changing XML"
    sed -i 's:<Order position="1" device="Floppy"/>:<Order position="1"  device="None"/>:g' *.ovf

    echo "... regenerating SHA1 sums"
    # recalc SHA1
    (
    for i in *.vmdk *.ovf;
    do
	ss=$(sha1sum $i | awk '{print $1}')
	echo "SHA1 ($i)= $ss"
    done
    ) > *.mf

    echo "... repackaging OVA"
    tar -cf $targetdir$/${NAME}.ova *.ovf *.mf *.vmdk

    cd /tmp
    echo "... cleaning up"
    rm -rf $workdir $targetdir$/${NAME}.tar
    echo "done."
fi

echo "Your appliance is ready at $targetdir$/${NAME}.ova"

