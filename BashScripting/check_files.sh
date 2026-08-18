#!/bin/bash

x="$@"
if [ -f $1 ]; then
	path=$(realpath "$x")
	size=$(stat -c%s "$@")
	echo "File ${x} found and has $size bytes and is $path"
else
	echo "File ${x} not found"
fi
