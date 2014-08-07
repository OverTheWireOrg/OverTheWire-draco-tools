#!/usr/bin/env python
import sys
from netaddr import IPNetwork

lines = [x.strip() for x in open(sys.argv[1]).readlines() if "your allocated network is" in x]

if len(lines) != 1:
    sys.exit(1)

parts = [x for x in lines[0].split(" ") if x != ""]

iprange = parts[5]
netinfo = IPNetwork(iprange)
first = netinfo[2]
last = netinfo[-2]
gw = netinfo[1]

print """
default-lease-time 600;
max-lease-time 7200;

subnet %s netmask %s {
   range %s %s;
   option routers %s;
   option domain-name-servers 8.8.8.8;
}
""" % (netinfo.ip, netinfo.netmask, first, last, gw)

sys.exit(0)
