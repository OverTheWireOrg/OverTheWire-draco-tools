Draco Tools
===========

This repository hosts end-user tools to connect to the OverTheWire warzone.
More information about this warzone can be found on [https://draco.overthewire.org](https://draco.overthewire.org).


Connecting vulnerable machines to the warzone with a "router" account is not
trivial. To get started easily, this repository contains tools to build a virtual
virtual VPN router image that can be used to easily connect vulnerable hosts to
the warzone.

The router offers:
- separation of the VPN credentials away from any hosted vulnerable images.
- abstraction away from the VPN network setup: vulnerable hosts need not be aware that they are on a VPN network.

The router image is built in such a way that it can be distributed as-is.
User-specific configuration is applied from a virtual floppy-disk image, containing
the VPN credentials and (sub)network configuration.

Building instructions
---------------------

To build a VM image, create a configfile in config/ and run "sudo ./build-vm.sh config/myconfig.ini".
There is support to build router images and vulnerable hosts in both OVA and libvirt format.

Download an OVA version of the router image here: [http://images.overthewire.org/dracorouter.ova](http://images.overthewire.org/dracorouter.ova)
This image was built using ```sudo ./build-vm.sh config/dracorouter-ova.ini```
