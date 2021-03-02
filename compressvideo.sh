#!/bin/bash


if [[ "$1" == "mp2" ]] 
then
	ffmpeg -i $2 -vcodec h264 -acodec mp2 $3
elif [[ "$1" == "aac" ]] 
then
	ffmpeg -i $2 -vcodec h264 -acodec aac $3
elif [[ "$1" == "mp3" ]] 
then
	ffmpeg -i $2 -vcodec h264 -acodec mp3 $3
fi