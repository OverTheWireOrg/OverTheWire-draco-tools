Draco Tools
===========

OverTheWire's warzone network code-named "Draco" allows registered users to connect
to an isolated network full of vulnerable hosts and services to practice penetration
testing.

Once connected, a subnet with a fixed IP-range is routed towards connected clients 
with "server" accounts. This IP-range can then be used to add vulnerable hosts to the
warzone.

This repository hosts scripts to build a virtual VPN router image that can be used to
easily connect to the Draco network.

The router offers:
- separation of the VPN credentials away from any hosted vulnerable images.
- abstraction away from the VPN network setup: vulnerable hosts need not be aware that they are on a VPN network.

The router image is built in such a way that it can be distributed as-is.
User-specific configuration is applied from a virtual floppy-disk image, containing
the VPN credentials and (sub)network configuration.

[Connecting with client credentials](src/master/ConnectWithClientCredentials.md)

Building instructions
---------------------

To build a VM image, create a configfile in config/ and run "sudo ./build-vm.sh config/myconfig.ini".
There is support to build router images and vulnerable hosts in both OVA and libvirt format.

