#!/bin/bash

localTest=false

floppy=/media/floppy
floppydev=/dev/fd0
vpndir=/etc/openvpn/
roothome=/root/
thisdir=/usr/bin/

if $localTest;
then
    tmpdir=/tmp/xxx
    floppy=$tmpdir/media/floppy
    floppydev=$tmpdir/dev/fd0
    vpndir=$tmpdir/etc/openvpn/
    roothome=$tmpdir/root/
    thisdir=.
fi

dialog=dialog

function isValidUsername() { #{{{
    x=$(echo "$1" | tr -d "a-zA-Z0-9_-")
    l=$(echo "$1" | wc -c)
    [ $l -ge 1 -a $l -le 32 -a -z "$x" ]
}
#}}}
function generateRandomUsername() { #{{{
    $thisdir/randomUsername.py
}
#}}}
function floppyMounted() { #{{{
    x=$(mount -l | awk "\$1 == \"$floppydev\" && \$3 == \"$floppy\" && \$6 == \"(rw)\"")
    [ ! -z "$x" ]
}
#}}}
function mountFloppy() { #{{{
	if $localTest;
	then
	    sudo mount -o loop $floppydev $floppy
	else
	    sudo mount $floppydev $floppy
	fi
}
#}}}
function promptFormat() { #{{{
    if $dialog --ascii-lines --no-shadow --yesno "Format floppy?\n\
\n\
ATTENTION!!!!!\n\
\n\
Floppy $floppydev is not mounted read/write on $floppy\n\
It is possible that your floppy is not formatted yet.\n\
\n\
Would you like to format now?\n\
    " 20 60;
    then
	dd if=/dev/zero bs=512 count=2880 of=$floppydev
        /sbin/mkfs.ext2 -F $floppydev
	mountFloppy
    else
	exit 1
    fi
}
#}}}
function msgFormatFailed() { #{{{
    dialog --ascii-lines --no-shadow --yesno "Format failed :(\n\
Is there an empty floppy in the floppy drive?" 20 60;
}
#}}}
function keyInFloppyRoot() { #{{{
    x=$(echo $floppy/*.key)
    [ -e "$x" ]
}
#}}}
function keyInOpenVPNDir() { #{{{
    x=$(echo $vpndir/*.key)
    [ -e "$x" ]
}
#}}}
function downloadAndInstallConfig() { #{{{
    if $dialog --ascii-lines --no-shadow --yesno "Download and install configuration to floppy...\n\
\n\
The private key found in the root of your floppy will be used to download your
configuration and update the configuration floppy.
\n\
THIS WILL FORMAT YOUR FLOPPY. ARE YOU SURE?\n\
THIS WILL FORMAT YOUR FLOPPY. ARE YOU SURE?\n\
THIS WILL FORMAT YOUR FLOPPY. ARE YOU SURE?\n\
    " 20 60;
    then
        if $thisdir/createFloppyTarball.sh $roothome $floppy/*.key;
        then
            if $dialog --ascii-lines --no-shadow --yesno "To complete this step, you have to reboot\n\
        \n\
        Reboot now?\n\
        \n\
            " 20 60;
            then
	    	    if $localTest;
		    then
			echo "Would reboot now..."
			read
		    else
                        sudo reboot
		    fi
            fi
	else
	    echo "Press enter to continue"
	    read
            dialog --ascii-lines --no-shadow --yesno "downloading and installing the configuration failed :(" 20 60;
	    exit 1
        fi
    fi
}
#}}}
function promptRegister() { #{{{
    if $dialog --ascii-lines --no-shadow --yesno "Create account\n\
\n\
You either have no account, or have no setup the configuration floppy properly.\n\
\n\
Would you like to create an account now?\n\
    " 20 60;
    then
	# create a ssl keypair on the floppy, key named .tmp in case of a reboot...
	openssl req -new -newkey rsa:2048 -nodes -out $floppy/user.csr -keyout $floppy/user.key.tmp -subj "/"
	nameFile=$(mktemp)
	currname=$(generateRandomUsername)
	done=false
	while ! $done;
	do
	    if [ "$dialog" = "dialog" ]; then
		dialog --inputbox "Choose an account name, 32 char max, [a-zA-Z0-9_-]+" 20 60 "$currname" 2> $nameFile
		currname=$(cat $nameFile)
	    fi
	    
	    echo "name = [$currname]"
	    if [ "$currname" == "" ];
	    then
		exit 1
	    fi

	    if ! $(isValidUsername "$currname");
	    then
		dialog --msgbox "Invalid username. It should be 32 char max, [a-zA-Z0-9_-]+" 20 60
	    else 
		msgFile=$(mktemp)
		if ! $thisdir/registerAccountOnline.py "$currname" "$floppy/user.csr" > $msgFile;
		then
		    reason=$(cat $msgFile)
		    dialog --msgbox "Registration of username "$currname" failed because:\n\n$reason" 20 60
		else
		    mv $floppy/user.csr "$floppy/$currname.csr"
		    mv $floppy/user.key.tmp "$floppy/$currname.key"
		    $dialog --msgbox "Registration of username "$currname" successful" 20 60
	    	    downloadAndInstallConfig
		fi
	    fi

	done
    else
	exit 1
    fi
}
#}}}
function autoRegister() { #{{{
    x=$(echo $floppy/autoreg.txt)
    [ -e "$x" ]
}
#}}}

# if floppy isn't mounted, try to mount.
if ! $(floppyMounted); then mountFloppy; fi
# if still not mounted, prompt to format and mount
if ! $(floppyMounted); then promptFormat; fi
# while not mounted, keep trying to reformat
while ! $(floppyMounted); do msgFormatFailed; promptFormat; done

# if $floppy/autoreg.txt exists, we are in automode, don't ask questions and just register
if $(autoRegister); 
then 
    dialog=true
fi

# if there is a floppy with a key in the root, prompt for recreate
if $(keyInFloppyRoot); 
then 
    downloadAndInstallConfig;
else
    # if there is no /key and no /etc/openvpn/*.key, prompt to create
    if ! $(keyInOpenVPNDir);
    then
	promptRegister
    else
	echo -n ""
	# otherwise, everything is ok
    fi
fi

exit 0
