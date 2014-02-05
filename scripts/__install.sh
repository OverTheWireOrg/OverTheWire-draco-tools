#!/bin/bash

for s in $datadir$/install-scripts.d/*; do
    echo "Executing $s"
    ./$s
done
