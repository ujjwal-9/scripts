#!/bin/bash
ffmpeg -i $1 -q:a 0 -map a $2

