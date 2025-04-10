#!/bin/bash

while true
do
    echo "Active SSH connections:"
    netstat -tn | grep ':22 ' | grep ESTABLISHED
    echo ""
    sleep 2
done
