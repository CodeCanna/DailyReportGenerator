#!/bin/bash

# Check if script is ran as root
if [ $USER != 'root' ];then
    echo "This script must be ran as root...";
    exit 1;
fi

