#!/bin/bash

# Check if script is ran as root
if [ $USER != 'root' ];then
    echo "This script must be ran as root...";
    exit 1;
fi

# Define install directory
install_dir=/bin;

# Define lib directory
lib_dir=/lib;

# Remove library
rm -rf $lib_dir/GenReport;
if [ "$?" != 0 ]; then
    echo "There was a problem removing $lib_dir/GenReport";
    exit 1;
fi

# Remove gen-report
rm -f $install_dir/gen-report;
if [ "$?" != 0 ]; then
    echo "There was a problem removing $install_dir/gen-report";
    exit 1;
fi

echo "Uninstall Successfull!";