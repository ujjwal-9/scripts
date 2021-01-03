#!/bin/bash

# Generate gif from video file
# Usage: gif.sh <video file> <output gif file> <0 if use whole video else 1 to trim for gif>


if [[ $3 -ge 1 ]]
then
	read -p 'Enter Start Time (00:00:00): ' start
	read -p 'Enter End Time (00:00:00): ' end
	ffmpeg -i $1 -ss $start -pix_fmt rgb24 -r 10 -t $end $2
else
	ffmpeg -i $1 -pix_fmt rgb24 $2
fi
