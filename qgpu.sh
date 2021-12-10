#!/bin/bash

ssh_key=/home/ujjwal/.ssh/qureipa

declare -a ip_list=('192.168.1.23' '192.168.1.22' '192.168.1.21' '192.168.1.20' '192.168.1.19' '192.168.1.18' '192.168.1.17' '192.168.1.16' '192.168.1.15' '192.168.1.13' '192.168.1.11');

for i in ${ip_list[@]} ; do
    echo "Server IP: $i"
    ssh -i $ssh_key ujjwal.upadhyay@$i "gpustat"
done
