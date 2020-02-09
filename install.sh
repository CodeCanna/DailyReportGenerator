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
lib_dir=/lib/GenReport;

# Define help_doc directory
help_dir=/usr/share;

# GenReport Installer
function install_genreport() {
    echo "Starting install";
    
    # Create lib directory if it does NOT exist
    if [ ! -d "$lib_dir" ]; then
        sleep 0.5;
        
        if (! mkdir --verbose --parents "$lib_dir") then
            echo "Couldn't create $lib_dir";
            exit 1;
        fi
    fi
    
    if [ ! -d "$exp_dir" ]; then
        sleep 0.5;
        
        if (! mkdir --verbose --parents "$exp_dir" && chown "$SUDO_USER" "$exp_dir") then
            echo "Problem creating directory $exp_dir";
        fi
    fi
    
    # Install GenReport Library
    sleep 0.5;
    if (! cp --recursive --force --verbose ./lib/* $lib_dir) then
        echo "There was a problem copying ./lib to $lib_dir";
        exit 1;
    fi
    
    # Install test library
    sleep 0.5
    if(! cp --recursive --force --verbose ./test "$lib_dir") then
        echo "There was a problem installing the test library...";
        exit 1;
    fi
    
    # Install help doc
    sleep 0.5;
    if (! cp --force --verbose ./help_doc.txt "$help_dir") then
        echo "There was a problem copying ./help_doc.txt to $help_dir";
        exit 1;
    fi
    
    # Install GenReport
    sleep 0.5;
    if (! cp --recursive --force --verbose ./gen-report "$install_dir") then
        echo "There was a problem copying ./gen-report to $install_dir";
        exit 1;
    fi
    
    return 0;
}

# GenReport Uninstaller
function uninstall_genreport() {
    # Check if GenReport is even installed
    if [ ! -f /bin/gen-report ]; then
        echo "GenReport not found, Nothing to do...";
        exit 1;
    fi
    
    # Remove export directory
    sleep 0.5;
    if (! rm --recursive --force --recursive --force --verbose "$exp_dir") then
        echo "There was a problem removing $exp_dir";
        exit 1;
    fi
    
    # Remove libraries
    sleep 0.5;
    if (! rm --recursive --force --recursive --force --verbose "$lib_dir") then
        echo "There was a problem removing $lib_dir/GenReport";
        exit 1;
    fi
    
    # Remove test library
    
    # Remove gen-report
    sleep 0.5;
    if (! rm --force --verbose "$install_dir/gen-report") then
        echo "There was a problem removing $install_dir/gen-report";
        exit 1;
    fi
    
    # Remove help_doc
    sleep 0.5;
    if (! rm --force --verbose "$help_dir"/help_doc.txt) then
        echo "Couldn't remove $help_dir/help_doc.txt";
        exit 1;
    fi
    
    return 0;
}

case $1 in
    '--uninstall')
        if (! uninstall_genreport) then
            # Exit in failure
            echo "Uninstallation Failed...";
            exit 1;
        fi
        
        # Exit sucessfully
        echo "Uninstallation Sucessful!!";
        exit 0;
    ;;
    '-h' | '--help')
        echo "Run [sudo ./install.sh] to install GenReport.";
        echo "Run [sudo ./install.sh --uninstall] to uninstall GenReport";
    ;;
    '' | ' ')
        if (! install_genreport) then
            echo "Installation Failed...";
            exit 1;
        fi
        
        echo "Installation Sucessful!!"
        exit 0;
    ;;
    *)
        echo "Run [sudo ./install.sh] to install GenReport.";
        echo "Run [sudo ./install.sh --uninstall] to uninstall GenReport";
    ;;
esac