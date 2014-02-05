#!/bin/bash

for s in install-scripts.d/*; do
    echo "Executing $s"
    ./$s
done
