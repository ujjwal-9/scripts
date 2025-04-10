#!/bin/bash

USER=x_upadhyu

if [[ "$1" == "vpn" ]] 
then 
    sudo openconnect --server vpn.kaust.edu.sa --user "$USER" --authgroup "External-Users" --protocol anyconnect --servercert pin-sha256:CZthMP/1y7i9aDDKYPhUWJegKWEPMVcf235OJtRYpAA= 
elif [[ "$1" == "ibex" ]] 
then 
    ssh "$USER"@glogin.ibex.kaust.edu.sa 
elif [[ "$1" == "shaheen" ]] 
then ssh "$USER"@shaheen.hpc.kaust.edu.sa 
else 
    ssh "$USER"@"$1".kaust.edu.sa 
fi
