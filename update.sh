#!/bin/bash

#Usage: update.sh <app-name>

echo "updating ${1} ..."


if [[ "$1" == "zoom" ]] 
then
	rm ~/Downloads/zoom_amd64.deb
	wget https://us04web.zoom.us/client/latest/zoom_amd64.deb -P ~/Downloads
	sudo dpkg -i ~/Downloads/zoom_amd64.deb
elif [[ "$1" == "nteract" ]]
then
	cd ~/Downloads; 
	rm ~/Downloads/nteract*
	gh release download --pattern '*.deb' --repo https://github.com/nteract/nteract/
	sudo dpkg -i ~/Downloads/nteract*.deb
fi