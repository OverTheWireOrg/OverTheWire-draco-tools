#!/bin/bash

tmpdir=$(mktemp -d /tmp/XXXXXXXXXXXXXXXXXXXXX)

rsync -rv --exclude=.git . $tmpdir

find $tmpdir -type f -exec ./scripts/apply_template_inplace.py config/badidea.ini {} \;

#launch buildtools
#maybe copy files somewhere


#rm -rf $tmpdir
echo look in $tmpdir
