#!/bin/bash

if [[ "$1" == "start" ]]
then
	make -C $outline_dir start
elif [[ "$1" == "stop" ]] 
then
	make -C $outline_dir stop
fi
