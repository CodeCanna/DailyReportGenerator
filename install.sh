#!/bin/bash

# Set posix mode
set -o posix;

# Check if script is ran as root
if [ "$USER" != 'root' ];then
    echo "This script must be ran as root...";
    exit 1;
fi

# Define export directory
exp_dir=/home/$SUDO_USER/Documents/Work/Notes;

# Define install directory
install_dir=/bin;
    
# Define GenReport library directory
lib_dir=/lib/GenReport/;

# Define help_doc directory
help_dir=/usr/share;

function install_genreport() {
    echo "Starting install";

    # Create lib directory if it does NOT exist
    if [ ! -d "$lib_dir" ]; then
        echo "Creating $lib_dir";
        sleep 0.5;
        
        if (! mkdir --parents "$lib_dir") then
            echo "Couldn't create $lib_dir";
            exit 1;
        fi
    fi
    
    if [ ! -d "$exp_dir" ]; then
        echo "Creating directory $exp_dir";
        sleep 0.5;
        
        if (! mkdir --parents "$exp_dir" && chown "$SUDO_USER" "$exp_dir") then
            echo "Problem creating directory $exp_dir";
        fi
    fi
    
    # Install GenReport
    echo "Installing GenReport at $install_dir";
    sleep 0.5;
    if (! cp ./gen-report "$install_dir") then
        echo "There was a problem copying ./gen-report to $install_dir";
        exit 1;
    fi
    
    # Install GenReport Library
    echo "Installing GenReport/lib at $lib_dir";
    sleep 0.5;
    if (! cp -r ./lib/* $lib_dir) then
        echo "There was a problem copying ./lib to $lib_dir";
        exit 1;
    fi

    # Install help doc
    echo "Copying ./help_doc.txt to $help_dir";
    sleep 0.5;
    if (! cp ./help_doc.txt "$help_dir") then
        echo "There was a problem copying ./help_doc.txt to $help_dir";
        exit 1;
    fi
    
    echo "Installation Sucessfull!!";
}

function uninstall_genreport() {    
    # Remove export directory
    echo "Removing $exp_dir";
    sleep 0.5;
    if (! rm -rf "$exp_dir") then
        echo "There was a problem removing $exp_dir";
        exit 1;
    fi
    
    # Remove library
    echo "Removing $lib_dir";
    sleep 0.5;
    if (! rm -rf "$lib_dir") then
        echo "There was a problem removing $lib_dir/GenReport";
        exit 1;
    fi
    
    # Remove gen-report
    echo "Uninstalling GenReport";
    sleep 0.5;
    if (! rm -f "$install_dir/gen-report") then
        echo "There was a problem removing $install_dir/gen-report";
        exit 1;
    fi

    # Remove help_doc
    echo "Removing $help_dir/help_doc.txt";
    sleep 0.5;
    if (! rm -f "$help_dir"/help_doc.txt) then
        echo "Couldn't remove $help_dir/help_doc.txt";
        exit 1;
    fi
    
    echo "Uninstall Successfull!";
}

case $1 in
    '--uninstall')
        uninstall_genreport;
        exit 0;
    ;;
    '' | ' ')
        install_genreport;
        exit 0;
    ;;
    *)
        echo "Run [sudo ./install.sh] to install GenReport.";
        echo "Run [sudo ./install.sh --uninstall] to uninstall GenReport";
    ;;
esac