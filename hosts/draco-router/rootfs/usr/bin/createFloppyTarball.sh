#!/bin/bash

set -e
shopt -s nullglob

distdir=/etc/warzone-draco-floppyrootfs
roothome=$1
keyfile=$2

mkdir -p $roothome

if [ -z "$keyfile" ];
then
	echo "No keyfile"
	exit 0
fi
echo "Keyfile is at $keyfile"

# Extract username
username=$(basename $keyfile .key)
tarballurl="https://draco.overthewire.org/s/tarball/$username"
tarball="/tmp/$username.tar.gz"
echo "Username is $username, tarball at $tarballurl and $tarball"

# Download tarball
function isValidTarball() {
    if [ ! -e "$1" ]; 
    then
    	false;
    else
        ! grep -q "Tarball not available" "$1"
    fi
}

while ! $(isValidTarball "$tarball");
do
    wget --no-check-certificate -O "$tarball" "$tarballurl"
    if ! $(isValidTarball "$tarball");
    then
        echo "Tarball is not available yet. Retrying in 10 seconds..."
	sleep 10
    fi
done

# create a workdir and unpack the tarball
tmpdir=$(mktemp -d)
cp -r $distdir/* $tmpdir || true
pushd $tmpdir
	mkdir -p network openvpn warzone
	tar -xf $tarball

	# copy network config
	mv interfaces.example network/interfaces

	# copy key and certificates to openvpn and warzone config
	cp $keyfile openvpn/$username.key
	chmod go= openvpn/$username.key
	cp $keyfile warzone/registry.key
	chmod go= warzone/registry.key
	mv $username.crt $username.ca.crt $username.conf openvpn/
	mv $username.registry.ca.crt warzone/registry.ca.crt
	mv $username.registry.crt warzone/registry.crt

	# make a copy of the vulnhost descriptions
	cp /etc/registryUpdater/* registryUpdater/ || true

	# make a copy of the firewall state too
	mkdir -p shorewall/rules.d/ && cp /etc/shorewall/rules.d/*.rules shorewall/rules.d/ || true
	mkdir -p shorewall/masq.d/ && cp /etc/shorewall/masq.d/*.masq shorewall/masq.d/	|| true
	mkdir -p warzone/state && cp /etc/warzone/state/* warzone/state/ || true

	tar -czf $roothome/newfloppy.tgz .
popd

rm -rf $tmpdir $tarball

# new floppy image is ready to be placed on floppy
# but everything must be stopped, unmounted and whatnot
# so instead, we just wait until next reboot...

exit 0
