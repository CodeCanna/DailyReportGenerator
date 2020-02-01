#!/bin/bash

# Set posix mode
set -o posix;

# Check if script is ran as root
if [ $USER != 'root' ];then
    echo "This script must be ran as root...";
    exit 1;
fi

# Define export directory
exp_dir=/home/$SUDO_USER/Documents/Work/Notes;

# Define install directory
install_dir=/bin;
    
# Define GenReport library directory
lib_dir=/lib/GenReport/;

function install_genreport() {
    echo "Starting install";

    # Create lib directory if it does NOT exist
    if [ ! -d "$lib_dir" ]; then
        echo "Creating $lib_dir";
        sleep 0.5;
        
        mkdir --parents "$lib_dir";
        if [ "$?" != 0 ]; then
            echo "Couldn't create $lib_dir";
            exit 1;
        fi
    fi
    
    if [ ! -d "$exp_dir" ]; then
        echo "Creating directory $exp_dir";
        sleep 0.5;
        
        mkdir --parents "$exp_dir";
        if [ "$?" != 0 ]; then
            echo "Problem creating directory $exp_dir";
        fi
    fi
    
    # Install GenReport
    echo "Installing GenReport at $install_dir";
    sleep 0.5;
    cp ./gen-report "$install_dir";
    if [ "$?" != 0 ]; then
        echo "There was a problem copying ./gen-report to $install_dir";
        exit 1;
    fi
    
    # Install GenReport Library
    echo "Installing GenReport/lib at $lib_dir";
    sleep 0.5;
    cp -r ./lib/* $lib_dir;
    if [ "$?" != 0 ]; then
        echo "There was a problem copying ./lib to $lib_dir";
        exit 1;
    fi
    
    echo "Installation Sucessfull!!";
}

function uninstall_genreport() {    
    # Remove export directory
    rm -rf $exp_dir && echo "Removing $exp_dir" && sleep 0.5;
    if [ "$?" != 0 ]; then 
        echo "There was a problem removing $exp_dir";
        exit 1;
    fi
    
    # Remove library
    rm -rf $lib_dir && echo "Removing $lib_dir" && sleep 0.5;
    if [ "$?" != 0 ]; then
        echo "There was a problem removing $lib_dir/GenReport";
        exit 1;
    fi
    
    # Remove gen-report
    rm -f $install_dir/gen-report && echo "Uninstalling GenReport" && sleep 0.5;
    if [ "$?" != 0 ]; then
        echo "There was a problem removing $install_dir/gen-report";
        exit 1;
    fi
    
    echo "Uninstall Successfull!";
}

case $1 in
    '--uninstall')
        uninstall_genreport;
        exit 0;
    ;;
    '')
        install_genreport;
        exit 0;
    ;;
    *)
        echo "Run [sudo ./install.sh] to install GenReport.";
        echo "Run [sudo ./install.sh --uninstall] to uninstall GenReport";
    ;;
esac