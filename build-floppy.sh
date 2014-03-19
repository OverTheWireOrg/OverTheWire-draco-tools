#!/bin/bash

if [ ! -e "$1" -o ! -e "$2" ];
then
    echo "Not enough arguments or listed files don't exist"
    echo "Usage: $0 <tarball> <SSL key> [<optional outfile>]"
    exit 0
fi

distdir=$(dirname $(readlink -f $0))
inf=$(readlink -f $1)
key=$(readlink -f $2)
outf=${3:-$inf.img}

here=$(pwd)
tmpdir=$(mktemp -d)
cp -r $distdir/floppyrootfs/* $tmpdir/
cd $tmpdir
mkdir -p network openvpn warzone
tar -xf $inf

# extract username
username=$(basename *.registry.crt .registry.crt)

# network config
mv interfaces.example network/interfaces

# copy key and certificates to openvpn and warzone config
cp $key openvpn/$username.key
chmod go= openvpn/$username.key
cp $key warzone/registry.key
chmod go= warzone/registry.key
mv $username.crt $username.ca.crt $username.conf openvpn/
mv $username.registry.ca.crt warzone/registry.ca.crt
mv $username.registry.crt warzone/registry.crt

cd $here

sudo $distdir/scripts/linux_dir_to_floppy_img.sh $tmpdir $outf

rm -rf $tmpdir
