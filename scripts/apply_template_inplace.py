#!/usr/bin/python

import sys, os.path
import ConfigParser

if len(sys.argv) < 3:
    print "Usage: %s <configfile> <filepath>" % sys.argv[0]
    sys.exit(1)

config = sys.argv[1]
template = sys.argv[2]
out = template

if not os.path.exists(config) or not os.path.exists(template):
    print "Configfile %s or template file %s doesn't exist" % (config, template)
    sys.exit(1)

cp = ConfigParser.SafeConfigParser()
cp.optionxform = str
cp.read([config])

text = open(template).read()

print "Generating %s with config %s ..." % (template, config)

for section in cp.sections():
    for key, value in cp.items(section):
    	if key != key.lower():
	    print "Warning: '%s' in section '%s' is not lowercase! All key names must be lowercase because python's ConfigParser is case insensitive" % (key, section)
	    sys.exit(1)

	oldtext = text
	text = text.replace(key, value)
	if oldtext != text:
	    print "  [%s] Replaced '%s' with '%s'" % (section, key.lower(), value)

open(out, "w").write(text)
sys.exit(0)
