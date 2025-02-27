#!/bin/sh
DIR="build"
rm -f $DIR.zip
cd $DIR && zip -r ../$DIR.zip . -x "options.html" "_metadata/*"
