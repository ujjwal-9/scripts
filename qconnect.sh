#!/bin/bash

qure1=192.168.1.11
qure3=192.168.1.13
qure5=192.168.1.15
qure7=192.168.1.17
qure9=192.168.1.19
qure11=192.168.1.21


server_ip="192.168.1.$1"
echo "Server IP: $server_ip"

ssh -i ~/.ssh/qureipa ujjwal.upadhyay@$server_ip
