#!/bin/bash

if [[ "$1" == "zoom" ]] 
then
	echo "updating ${1} ..."
	rm ~/Downloads/zoom_amd64.deb
	wget https://us04web.zoom.us/client/latest/zoom_amd64.deb -P ~/Downloads
	sudo dpkg -i ~/Downloads/zoom_amd64.deb
fi