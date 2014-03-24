#!/bin/bash

if [ ! -e "$1" -o ! -e "$2" ];
then
    echo "Not enough arguments or listed files don't exist"
    echo "Usage: $0 <tarball> <SSL key>"
    exit 0
fi

distdir=$(dirname $(readlink -f $0))
inf=$(readlink -f $1)
key=$(readlink -f $2)
outf=$inf.img

here=$(pwd)
tmpdir=$(mktemp -d)
cd $tmpdir
tar -xf $inf

# extract username
username=$(basename *.registry.crt .registry.crt)
echo "[DEBUG] Your username: $username"

# copy key
cp $key $username.key

hash1=$(openssl x509 -noout -modulus -in $username.registry.crt | openssl md5)
hash2=$(openssl rsa -noout -modulus -in $username.key | openssl md5)

if [ "$hash1" != "$hash2" ];
then
    echo
    echo "[ERROR] Your private key does not match the certificate. Are you using the correct private key?"
    echo
    cd $here
    rm -rf $tmpdir
    exit 1
fi


# Step 1: make openvpn credentials
tar -czf $here/$username-openvpn.tar.gz $username.ca.crt $username.conf $username.crt $username.key

# Step 2: make PKCS12 for the browser
echo "[DEBUG] You will be prompted for a password to protect the PKCS12 file."
openssl pkcs12 -export -out $here/$username-registry.p12 -inkey $username.key -in $username.registry.crt

cd $here
rm -rf $tmpdir

echo
echo "Your OpenVPN credentials are in $username-openvpn.tar.gz"
echo "Your registry credentials are in $username-registry.p12"
echo

exit 0
