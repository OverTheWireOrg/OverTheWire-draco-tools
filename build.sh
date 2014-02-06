#!/bin/bash

conffile=$1

if [ ! -e "$conffile" ];
then
    echo "Usage: $0 <configfile>"
    echo "Given configfile not found"
    exit 0
fi

if [ "$UID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

tmpdir=$(mktemp -d /tmp/XXXXXXXXXXXXXXXXXXXXX)
rsync -rv --exclude=.git . $tmpdir
echo '$vmtype$' > $tmpdir/vmtype

find $tmpdir -type f -exec ./scripts/apply_template_inplace.py "$conffile" {} \;

here=$(pwd)
cd $tmpdir

vmtype=$(cat vmtype)
case $vmtype in
    libvirt)
	./scripts/create-libvirt-vm.sh
	;;
    ova)
	./scripts/make-ova-image.sh
	;;
esac

cd $here

rm -rf $tmpdir

