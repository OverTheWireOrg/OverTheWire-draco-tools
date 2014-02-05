#!/bin/bash

# This script is only used to transfer files between a main host and a VM on Steven's laptop

# copy all the files
ussh -p 2243 0 "rm -rf /tmp/badidea && mkdir -p /tmp/badidea/"
uscp -P 2243 -r . 0:/tmp/badidea/

