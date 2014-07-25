#!/usr/bin/env python
import sys
from netaddr import IPNetwork
import pprint, json

lines = [x.strip() for x in open(sys.argv[1]).readlines() if "your allocated network is" in x]

if len(lines) != 1:
    sys.exit(1)

parts = [x for x in lines[0].split(" ") if x != ""]

iprange = parts[5]

out = {}
for x in IPNetwork(iprange)[2:-1]:
   out["%s" % x] = {
        "tests": [ "ping" ],
	"title": "autodiscovered",
	"description": "autodiscovered",
	"REMOVEMEPLZ": "remove all the REMOVEMEPLZ lines so this configfile doesn't get overwritten"
   }

#pprint.pprint(out)
print json.dumps(out)
sys.exit(0)
