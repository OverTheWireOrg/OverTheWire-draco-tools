#!/bin/bash

inf=$(readlink -f $1)
outf=${2:-$inf.img}

if [ ! -e "$inf" ];
then
    echo "No arguments or file $inf doesn't exist"
    exit 0
fi

here=$(pwd)
tmpdir=$(mktemp -d)
cp -r floppyrootfs/* $tmpdir/
cd $tmpdir
tar -xf $inf
mv interfaces.example network/interfaces
mv *.crt *.csr *.key *.conf openvpn/
cd $here

sudo ./scripts/linux_dir_to_floppy_img.sh $tmpdir $outf

rm -rf $tmpdir
