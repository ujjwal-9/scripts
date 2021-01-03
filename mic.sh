#!/bin/bash
if [ $1 == 'load' ]
then
	pactl load-module module-echo-cancel 
	echo "Echo Cancel Module Loaded"
elif [ $1 == 'unload' ]
then
	pactl unload-module module-echo-cancel
	echo "Echo Cancel Module Unloaded"
else
	echo "Enter Arguement LOAD | UNLOAD"
fi