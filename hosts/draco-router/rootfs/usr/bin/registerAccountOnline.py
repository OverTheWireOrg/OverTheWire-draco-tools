#!/usr/bin/env python

import random, string, sys, urllib, urllib2, json

def randStr():
    return ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(32))

username = sys.argv[1]
csrpath = sys.argv[2]

csr = open(csrpath).read()

url = 'https://draco.overthewire.org/s/register'
token = randStr()
values = {
	    "username": username,
	    "type": "router",
	    "csr": csr,
	    "CSRFToken": token
}
headers = {
    'X-CSRF-Token': token,
    'Accept': 'application/json, text/plain, */*',
    'Content-Type': 'application/json;charset=UTF-8'
}

data = json.dumps(values)
req = urllib2.Request(url, data, headers=headers)

try:
    response = urllib2.urlopen(req)
    data = json.loads(response.read())
    print data["msg"]
    sys.exit(0 if data["success"] else 1)
except urllib2.HTTPError,e:
    print "EXCEPTION %s" % e.read()
    sys.exit(1)



