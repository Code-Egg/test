#!/bin/bash
if [ 'a' == 'b' ]; then
    echo 'T'
else
    echo 'F'
fi

if [ 'a' == 'b' ]; then
    echo 'T'
else
    echo 'F and exit'
    exit 1
fi   