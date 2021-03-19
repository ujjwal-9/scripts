#!/bin/bash

if [[ "$1" == "qure" ]]
then
	sudo openfortivpn -c ~/qurevpn.txt --trusted-cert e7b709832a359dcc4b894f2052402764360f97dc4aa6e1d64c145ea6ee25bf07
elif [[ "$1" == "kaust" ]] 
then
	if [[ "$2" == "disconnect" ]]
	then
		/opt/cisco/anyconnect/bin/vpn -s disconnect
	else
		/opt/cisco/anyconnect/bin/vpn -s connect vpn.kaust.edu.sa
	fi
fi