#!/bin/bash
size=$(stat -c%s "$1")
x="$1"
if [ -f $1 ]; then
	echo "File ${x} found and has $size bytes"
else
	echo "File ${x} not found"
fi
