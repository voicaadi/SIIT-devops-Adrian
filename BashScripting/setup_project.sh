#!/bin/bash

success=true

for i in 1 2 3 4 5;
do
	mkdir "module_$i"
	touch "module_$i/notes.md"
	
done
if $success; then
	echo "All repo and files are created"
else
	echo "something went wrong"
fi
