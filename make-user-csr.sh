#!/bin/bash

function makeKeyAndCSR() {
    countryCode=SE
    state=Gota
    city=Gothenburg
    company=OverTheWire
    organizationalUnitName=warzone
    email=admin@overthewire.org
    fnprefix="$1"
    bits=$2
    domain="$3"

    openssl req -nodes -newkey rsa:$bits -keyout "$fnprefix.key" -out "$fnprefix.csr" \
	-batch -subj "/C=$countryCode/ST=$state/L=$city/O=$company/OU=$organizationalUnitName/CN=$domain/emailAddress=$email"
}

username=$1

if [ "$username" = "" ];
then
    echo "Usage: $0 <username>"
    exit 0
fi

makeKeyAndCSR "$username" 1024 "$username"

