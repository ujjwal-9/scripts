#!/bin/bash

# Usage: wappfix.sh <video file>
ffmpeg -i $1 -c:v libx264 -profile:v baseline -level 3.0 -pix_fmt yuv420p $2
