#!/bin/bash

# Check if script is ran as root
if [ $USER != 'root' ];then
    echo "This script must be ran as root...";
    exit 1;
fi

# Define install directory
install_dir=/usr/bin/;

# Confirm the install directory exists
if [ ! -d $install_dir ];then
    echo "The required directory /usr/bin does not exist...";
    exit 1;
fi

rm -f /usr/bin/gen-report;
if [ $? != 0 ];then
    echo "There was a problem uninstalling gen-report.  Make sure this scirpt is being ran as root.  If this problem continues you can try running 'sudo rm -r /usr/bin/gen-report' to try removing it manually.";
    exit 1;
fi

echo "Unsinstallation Scuccessfull!!";
exit 0;