#!/bin/bash
ffmpeg -i $1 -pix_fmt rgb24 $2
