#!/bin/bash

if [[ "$1" == "vpn" ]]
then
    ssh_key=/home/ujjwal/.ssh/qureipa
    declare -a ip_list=('192.168.1.23' '192.168.1.22' '192.168.1.21' '192.168.1.20' '192.168.1.19' '192.168.1.18' '192.168.1.17' '192.168.1.16' '192.168.1.15' '192.168.1.13' '192.168.1.11');
    for i in ${ip_list[@]} ; do
        echo "Server IP: $i"
        ssh -i $ssh_key ujjwal.upadhyay@$i "gpustat"
    done
else
    declare -a ip_list=('qure13' 'qure12' 'qure11' 'qure10' 'qure9' 'qure8' 'qure7' 'qure6' 'qure5' 'qure3' 'qure1');
    for i in ${ip_list[@]} ; do
        echo "Server: $i"
        ssh ujjwal.upadhyay@$i.internal.qure.ai "gpustat"
    done
fi