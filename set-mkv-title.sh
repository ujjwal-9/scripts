#!/bin/bash

for mkvfile in *.mkv
do
    mkvpropedit "$mkvfile" -e info -s title="${mkvfile::-4}"
done