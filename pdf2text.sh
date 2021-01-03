#! /bin/sh

# Convert pdf to text
# Usage: pdf2text.sh <pdf file> <text file>

FOLDER=$(echo $1| cut -d'.' -f 1| cut -d'/' -f 5)
if [ -d /tmp/$FOLDER ]
then
	FOLDER = "${FOLDER}_NEW"
fi
mkdir /tmp/$FOLDER
pdftoppm -png $1 /tmp/$FOLDER/page
for f in /tmp/$FOLDER/page*; do tesseract $f $f; done
# FILE = $2
# echo $FILE
# if [ -f $2 ]
# then
# 	read -p 'File Already Exists. Enter New File Name: ' newname
# fi
cat /tmp/$FOLDER/*.txt > $2
rm -rf /tmp/$FOLDER/