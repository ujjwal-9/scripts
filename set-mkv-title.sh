#!/bin/bash

#usage set-mkv-title.sh

for mkvfile in *.mkv
do
    mkvpropedit "$mkvfile" -e info -s title="${mkvfile::-4}"
done