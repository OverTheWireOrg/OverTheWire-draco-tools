#!/bin/bash

baseDir=/etc/warzone/
interfacesconf=/etc/network/interfaces
firewallRulesd=/etc/shorewall/rules.d
firewallMasqd=/etc/shorewall/masq.d

sudo mkdir -p $baseDir/state

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
function getHostList() { #{{{
    mynet=$(grep 'your allocated network is' $interfacesconf | awk '{print $6}')
    # get all IPs, but skip network address, broadcast and this router's IP
    python -c "import sys; from netaddr import IPNetwork; print '\n'.join([str(x) for x in IPNetwork(sys.argv[1])])" $mynet |tail --lines=+3|head --lines=-1
}
#}}}
function getHostStatus() { #{{{
    ip=$1
    for state in Warzone Internet Offline;
    do
        if [ -e $baseDir/state/$ip.$state ];
	then
	    echo $state
	    return
	fi
    done

    # default state
    echo Warzone
}
#}}}
function setHostStatus() { #{{{
    mkdir -p $baseDir/state
    ip=$1
    state=$2

    if [ "$ip" != "" ];
    then
        sudo rm -f $baseDir/state/$ip.*
	sudo touch $baseDir/state/$ip.$state
    fi
}
#}}}
function queryHostStatus() { #{{{
    ip=$1
    s=$(getHostStatus $ip)
    s1="Off"
    s2="Off"
    s3="Off"

    if [ "$s" == "Warzone" ];
    then
	s1="On"
    fi

    if [ "$s" == "Internet" ];
    then
	s2="On"
    fi

    if [ "$s" == "Offline" ];
    then
	s3="On"
    fi

    mycmdFile=$(mktemp)
    dialog --radiolist "Select network status for $ip" 20 60 20 Warzone "" $s1 Internet "" $s2 Offline "" $s3 2> $mycmdFile
    cmd=$(cat $mycmdFile)
    case $cmd in
	Warzone|Internet|Offline)
		setHostStatus "$ip" "$cmd"
		;;
	*)
		return
		;;
    esac
}
#}}}
function updateFirewall() { #{{{
    for host in $(getHostList); do
	state=$(getHostStatus $host)

	# cleanup
        sudo rm -f $firewallRulesd/$host.rules $firewallMasqd/$host.masq

	# fill in template
	if [ "$state" != "" ];
	then
	    cat $firewallRulesd/$state.tmpl | sed "s:___IP___:$host:g" | sudo tee $firewallRulesd/$host.rules
	    cat $firewallMasqd/$state.tmpl | sed "s:___IP___:$host:g" | sudo tee $firewallMasqd/$host.masq
	fi
    done

    (sudo shorewall check && sudo shorewall restart) || (echo "Firewall restart failed. Press enter to continue."; read)
}
#}}}
function configFirewall() { #{{{
    while true; do
	hosts=""
	for i in $(getHostList);
	do
	    hosts="$hosts $i $(getHostStatus $i)"
	done

	netcmdFile=$(mktemp)
	dialog --nook --nocancel --ascii-lines --no-shadow --menu "Vulnerable host network status" 20 60 20 \
		$hosts \
		r "Reload firewall and return" \
		2> $netcmdFile

	ip=$(cat $netcmdFile)
	case $ip in
	    r)
		    updateFirewall
		    return
		    ;;
	    "")
	    	    return
		    ;;
	    *)
		    queryHostStatus $ip
		    ;;
	esac
    done

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
	if sudo /usr/bin/createFloppyTarball.sh;
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
function main() { #{{{
    cmdFile=$(mktemp)
    while true;
    do
	dialog --nook --nocancel --ascii-lines --no-shadow --menu "Draco router" 20 60 20 \
		t "Test Connection" \
		n "Place vulnhost in maintenance network" \
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
	    n)
		    configFirewall
		    ;;
	    c)
		    createConfig
		    ;;
	    "")
	    	    exit 0
		    ;;
	    *)
		    echo "Unknown character [$char]"
		    ;;
	esac
    done
}
#}}}

sudo /usr/bin/configureAccount.sh
main
