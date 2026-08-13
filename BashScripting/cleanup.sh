#!/bin/bash

count=$(find "$1" -type f -name "*.tmp" | wc -l)

find "$1" -type f -name "*.tmp" -delete

echo "Deleted $count .tmp files."
