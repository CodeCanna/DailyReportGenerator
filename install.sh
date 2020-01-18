#!/bin/bash

# Set posix mode
set -o posix;

# Check if script is ran as root
if [ $USER != 'root' ];then
    echo "This script must be ran as root...";
    exit 1;
fi

# Make gen-report executable
chmod +x ./gen-report;

# Get currently logged in user
CURRENT_USER=$(whoami);

# Define install directory
INSTALL_DIR=/usr/bin/;

# Define notes directory
NOTES_DIR=/home/$CURRENT_USER/Documents/Work/Notes/;

# Create notes directory if it doesn't exist
if [ ! -d $NOTES_DIR ];then
    mkdir $NOTES_DIR;
    if [ $? != 0 ];then
        echo "There was a problem creating a directory in $NOTES_DIR!  Make sure you have write access to that directory...";
        exit 1;
    fi
fi

# Confirm the install directory exists
if [ ! -d $INSTALL_DIR ];then
    echo "The required directory /usr/bin does not exist...that's may mean a big problem for your system...";
    exit 1;
fi

# Install gen-report
cp ./gen-report $INSTALL_DIR;
if [ $? != 0 ];then
    echo "There was a problem installing gen-report.  Make sure you are running this script as root, and the direcory /usr/bin/ exists...";
    exit 1;
fi

echo "Installation Successfull!!"
exit 0;