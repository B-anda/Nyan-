#!/bin/bash

stats = $()

for f in nyanTest/*.rb;
do 
    echo $f
    ruby "$f" | egrep 'Failure|Error|nyanTest|tests'
    echo ""
done

