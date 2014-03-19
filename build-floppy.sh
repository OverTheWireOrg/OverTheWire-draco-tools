#!/bin/bash

if [ ! -e "$1" -o ! -e "$2" ];
then
    echo "No arguments or listed files don't exist"
    echo "Usage: $0 <tarball> <SSL key> [<optional outfile>]"
    exit 0
fi

inf=$(readlink -f $1)
key=$(readlink -f $2)
outf=${3:-$inf.img}

here=$(pwd)
tmpdir=$(mktemp -d)
mkdir -p network openvpn warzone
cp -r floppyrootfs/* $tmpdir/
cd $tmpdir
tar -xf $inf

# extract username
username=$(basename *.registry.crt .registry.crt)

# network config
mv interfaces.example network/interfaces

# copy key and certificates to openvpn and warzone config
cp $key openvpn/$username.key
mv $username.crt $username.ca.crt $username.conf openvpn/
mv $username.registry.crt $username.registry.ca.crt warzone/

# make PKCS12 for the registry, empty password
openssl pkcs12 -passout pass: -export -in warzone/$username.registry.crt -inkey openvpn/$username.key -out warzone/registry.p12

cd $here

sudo ./scripts/linux_dir_to_floppy_img.sh $tmpdir $outf

rm -rf $tmpdir
