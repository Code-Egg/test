#!/bin/bash
if [ '${{ secrets.NAME }}' == 'abc' ]; then
    echo 'T'
else
    echo 'F'
fi
