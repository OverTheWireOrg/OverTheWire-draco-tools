#!/bin/bash

shopt -s nullglob

distdir=/etc/warzone-draco-floppyrootfs

# Mount the floppy first
mount /dev/fd0  &> /dev/null || true
mountPoint=$(mount -l | awk '$1 == "/dev/fd0" { print $3 }')

# Check whether there is a keyfile
keyfile=$(echo $mountPoint/*.key | cut -d' ' -f 1)

if [ -z "$keyfile" ];
then
	echo "No keyfile on floppy"
	exit 0
fi
echo "Keyfile is at $keyfile"

# Extract username
username=$(basename $keyfile .key)
tarballurl="https://draco.overthewire.org/s/tarball/$username"
tarball="/tmp/$username.tar.gz"
echo "Username is $username, tarball at $tarballurl and $tarball"

# Download tarball
wget --no-check-certificate -O "$tarball" "$tarballurl"

# create a workdir and unpack the tarball
tmpdir=$(mktemp -d)
cp -r $distdir/* $tmpdir/
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
	cp /etc/registryUpdater/* registryUpdater/

	# make a copy of the firewall state too
	mkdir -p shorewall/rules.d/ && cp /etc/shorewall/rules.d/*.rules shorewall/rules.d/
	mkdir -p shorewall/masq.d/ && cp /etc/shorewall/masq.d/*.masq shorewall/masq.d/
	mkdir -p warzone/state && cp /etc/warzone/state/* warzone/state/

	tar -czf /root/newfloppy.tgz .
popd

rm -rf $tmpdir $tarball

# new floppy image is ready to be placed on floppy
# but everything must be stopped, unmounted and whatnot
# so instead, we just wait until next reboot...

exit 0
