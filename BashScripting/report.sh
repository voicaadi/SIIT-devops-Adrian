#!/bin/bash

{
    echo "Current user: $(whoami)"
    echo "Current working directory: $(pwd)"
    echo "Last 5 lines of .bash_history:"
    tail -n 5 "$HOME/.bash_history" 2>/dev/null || ps
} > system_report.txt
