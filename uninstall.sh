#!/bin/bash

# Check if script is ran as root
if [ $USER != 'root' ];then
    echo "This script must be ran as root...";
    exit 1;
fi

# Get currently logged in user
CURRENT_USER=$(logname);

# Define install directory
install_dir=/usr/bin/;

# Confirm the install directory exists
if [ ! -d $install_dir ];then
    echo "The required directory /usr/bin does not exist...";
    exit 1;
fi

if (whiptail --title "Remove Notes Directory?" --yesno "Would you like to remove your notes directory?  THIS WILL DELETE ALL OF THE NOTES YOU HAVE STORED!!!" 12 60) then
    # Remove notes directory
    rm -rf /home/$CURRENT_USER/Documents/Work/Notes;
else
    exit 0;
fi



# Remove program files
rm -f /usr/bin/gen-report && rm -f /usr/bin/help_doc.txt;

if [ $? != 0 ];then
    echo "There was a problem uninstalling gen-report.  Make sure this scirpt is being ran as root.  If this problem continues you can try running 'sudo rm -r /usr/bin/gen-report' to try removing it manually.";
    exit 1;
fi

echo "Unsinstallation Scuccessfull!!";
exit 0;