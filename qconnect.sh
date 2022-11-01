#!/bin/bash

qure_user=ujjwal.upadhyay


qure1=192.168.1.11
qure3=192.168.1.13
qure5=192.168.1.15
qure7=192.168.1.17
qure9=192.168.1.19
qure11=192.168.1.21



if [[ $1 ]] && [ $1 -eq $1 2>/dev/null ]
then
  server_ip="192.168.1.$1"
  echo "Server IP: $server_ip"
  ssh -i ~/.ssh/qureipa $qure_user@$server_ip
else
  if [[ "$2" == "tunnel" ]]
  then
    kill -9 $(lsof -t -i:$3)
    tsh ssh -N -L $3:localhost:$3 $qure_user@$1.internal.qure.ai &
    jobs -l
  elif [[ "$2" == "sftp" ]]
  then
    sftp $qure_user@$1.internal.qure.ai
  elif [[ "$2" == "ext" ]]
  then
    tsh ssh $qure_user@$1
  else
    tsh ssh $qure_user@$1.internal.qure.ai
  fi
fi
