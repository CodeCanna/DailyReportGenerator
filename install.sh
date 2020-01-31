#!/bin/bash

# Set posix mode
set -o posix;

# Check if script is ran as root
if [ $USER != 'root' ];then
    echo "This script must be ran as root...";
    exit 1;
fi

# Define install directory
install_dir=/bin;

# Define GenReport library directory
lib_dir=/lib/GenReport/;

# Create lib directory if it does NOT exist
if [ ! -d "$lib_dir" ]; then
    mkdir "$lib_dir";
fi

# Install GenReport
cp ./gen-report "$install_dir";
if [ "$?" != 0 ]; then
    echo "There was a problem copying ./gen-report to $install_dir";
    exit 1;
fi

# Install GenReport Library
cp -r ./lib/* $lib_dir;
if [ "$?" != 0 ]; then
    echo "There was a problem copying ./lib to $lib_dir";
    exit 1;
fi

echo "Installation Sucessfull!!";