#!/bin/bash


function enterToContinue() {
    echo "=== Press enter to continue ==="
    read
}

function testConnection() { #{{{
    clear
    echo "Running network tests..."
    echo "+ Checking whether 8.8.8.8 is reachable"
    if ping -c 3 8.8.8.8;
    then
        echo "Looks ok"
    else
        echo "Failed: Internet connection seems down"
	enterToContinue
	return
    fi

    echo "+ Checking whether draco.overthewire.org is resolvable using 8.8.8.8"
    if host draco.overthewire.org 8.8.8.8;
    then
    	echo "Looks ok"
    else
        echo "Failed: DNS resolution by 8.8.8.8 seems broken"
	enterToContinue
	return
    fi

    echo "+ Checking whether draco.overthewire.org is resolvable using local DNS"
    if host draco.overthewire.org;
    then
    	echo "Looks ok"
    else
        echo "Failed: local DNS resolution seems broken"
	enterToContinue
	return
    fi

    echo "+ Checking whether draco.overthewire.org can be pinged"
    if ping -c 3 draco.overthewire.org;
    then
        echo "Looks ok"
    else
        echo "Failed: Could not ping draco.overthewire.org"
	enterToContinue
	return
    fi

    echo "+ Checking whether draco.overthewire.org listens to port 1195"
    if nc -w 3 -z draco.overthewire.org 1195;
    then
        echo "Looks ok"
    else
        echo "Failed: Could not connect to  draco.overthewire.org port 1195"
	enterToContinue
	return
    fi

    echo "+ Checking whether 172.27.0.1 can be pinged"
    if ping -c 3 172.27.0.1;
    then
        echo "Looks ok"
    else
        echo "Failed: Could not ping 172.27.0.1"
	enterToContinue
	return
    fi

    echo
    echo "Everything looks ok"
    echo
    enterToContinue
}
#}}}
function createConfig() { #{{{
    if dialog --ascii-lines --no-shadow --yesno "About to recreate the configuration floppy...\n\
\n\
assuming you placed your private key named <username>.key on the floppy\n\
\n\
THIS WILL OVERWRITE YOUR CONFIGURATION. ARE YOU SURE?\n\
THIS WILL OVERWRITE YOUR CONFIGURATION. ARE YOU SURE?\n\
THIS WILL OVERWRITE YOUR CONFIGURATION. ARE YOU SURE?\n\
    " 20 60;
    then
	if sudo /usr/bin/createFloppy.sh;
	then
	    enterToContinue
	    if dialog --ascii-lines --no-shadow --yesno "To complete this step, you have to reboot\n\
	\n\
	Reboot now?\n\
	\n\
	    " 20 60;
	    then
		    sudo reboot
	    fi
	else
	    enterToContinue
	fi
    fi
}
#}}}

function main() {
    cmdFile=$(mktemp)
    while true;
    do
	dialog --nook --nocancel --ascii-lines --no-shadow --menu "Draco router" 20 60 20 \
		t "Test Connection" \
		c "(Re)create floppy" \
		s "Exit and drop into a shell" \
		2> $cmdFile

	char=$(cat $cmdFile)
	case $char in
	    s)
		    exit 0
		    ;;
	    t)
		    testConnection
		    ;;
	    c)
		    createConfig
		    ;;
	    *)
		    echo "Unknown character [$char]"
		    ;;
	esac
    done
}

main
