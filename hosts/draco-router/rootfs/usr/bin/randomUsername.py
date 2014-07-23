#!/usr/bin/env python

from random import choice

# data ripped from https://github.com/aaronbassett/Pass-phrase

datadir="/opt/warzone/"

nouns=[x.strip() for x in open("%s/nouns.txt" % datadir).readlines()]
adj=[x.strip() for x in open("%s/adjectives.txt" % datadir).readlines()]


print "%s%s%d" % (choice(adj).capitalize(), choice(nouns).capitalize(), choice(range(100)))
