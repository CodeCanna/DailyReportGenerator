#!/bin/bash

set -o posix;

source /lib/GenReport/check_redis_connection.sh;
source /lib/GenReport/redis_connection.sh;
source /lib/GenReport/get.sh;

function set_report() {
    # Check for redis connection and if no connection is found then make one
    if (! has_redis_connection) then
        create_redis_connection;
    fi
    
    # Get date for file naming
    local DATE=$(date +%Y-%m-%d);
    
    local report_name=$1; # Key
    local report_content=$2 # Value;
    
    # Concat date with report name to create the naming convention I want
    local concatted_report_name="$report_name"'_'"$DATE";
    
    echo "$concatted_report_name" > /tmp/rpname.txt;
    
    concatted_report_name=/tmp/rpname.txt;
    
    # Remove spaces from report name and replace with underscores
    sed 's/ /_/g' "$concatted_report_name" > /tmp/rp_nospace_name.txt;
    
    concatted_nospace_report_name=$(cat /tmp/rp_nospace_name.txt);
    
    # Check if report exists
    report_exists "$concatted_nospace_report_name";
    if [ "$?" == 0 ]; then
        whiptail --yesno "This report already exists, would you like to edit it?" --yes-button "Edit" --no-button "Cancel" 10 70;
        if [ "$?" == 0 ]; then
            edit_report "$concatted_nospace_report_name";
        fi
    fi
    
    # Remove temporary files
    rm -f /tmp/rpname.txt;
    rm -f /tmp/rp_nospace_name.txt;
    
    # Verify arguments
    if [[ $report_name == 0 ]] || [[ $report_content == 0 ]]; then
        echo "Expecting two arguments got $#.  ";
        echo "Arguments expected [Arg1: \$report_name, Arg2: \$report_content]";
        return 1;
    fi
    
    # Verify report contents
    if [ -z $report_content ]; then
        echo "Something went wrong with inserting report."
        echo "Report content given: $2";
        echo "Report content: $report_content";
        
        exit 1;
    fi
    
    local report_string=$(stringify_report "$report_content");
    
    # Store data and save it to disk
    redis-cli set "$concatted_nospace_report_name" "$report_string" > /dev/null && redis-cli bgsave > /dev/null;
    if [ "$?" != 0 ]; then
        echo "There was a problem saving your reports database";
        echo "Your data is at rist of loss!";
        return 1;
    fi
    
    return 0;
}

function delete_report() {
    report_to_delete_key=$1;

    # If no redis connection is detected, create one
    if (! has_redis_connection) then
        create_redis_connection;
    fi

    report_exists "$report_to_delete_key";
    if [ "$?" != 0 ]; then
        echo "Report doesn't exist...";
        return 1;
    fi

    # Get the report the delete
    get_report "$report_to_delete_key" > /tmp/rpstring.txt;
    if [ "$?" != 0 ]; then
        return 1;
    fi

    # Delete report
    redis-cli del "$report_to_delete_key" > /dev/null;

    return 0;
}

function edit_report() {
    report_to_edit=$1;
    
    # Verify input
    if [ -z "$report_to_edit" ]; then
        echo "Edit report requires the redis key of the report that is to be edited...";
        return 1;
    fi
    
    #echo "Report to edit $report_to_edit";
    
    report_to_edit_string=$(get_report "$report_to_edit");
    
    unstringify_report "$report_to_edit_string" > /tmp/rpedit.txt;
    
    nano /tmp/rpedit.txt;
}

function stringify_report() {
    # Get report file as an argument
    report_file=$1;
    
    # Get client name for file naming convention
    client_name=$2;
    
    # Stringify file contents by removing all \n and spaces
    cat $report_file | tr '\n' ';' | tr ' ' '+' > /tmp/report_stringified.txt;
    
    report_file=/tmp/report_stringified.txt;
    
    # Store contents of /tmp/report_strin
    local report_string=$(cat "$report_file");
    
    rm -rf "$report_file";
    if [ -f "$report_file" ]; then
        echo "There was a problem removing temporary file $report_file, make sure you have corret permissions...";
        return 1;
    fi
    
    # Remove temporary files
    rm -f /tmp/report_stringified.txt;
    
    # Display result
    echo "$report_string";
    return 0;
}

function unstringify_report() {
    report_string=$1;
    
    # Write report string to /tmp/report_stringified.txt and set it to $report_stringified_file
    echo "$report_string" > /tmp/report_stringified.txt && local report_stringified_file=/tmp/report_stringified.txt;
    
    cat "$report_stringified_file" | tr ';' '\n' | tr '+' ' ' > /tmp/report_unstringified_file.txt;
    if [ "$?" != 0 ]; then
        echo "There was a problem unstringifying the report...";
        return 1;
    fi
    
    # Store the unstringified report file in /tmp
    local report_unstringified_file=/tmp/report_unstringified_file.txt;
    
    report_unstringified=$(cat "$report_unstringified_file");
    
    # Make sure /tmp/$report_unstringified_file got deleted
    rm -rf $report_unstringified_file;
    if [ -f "$report_unstringified_file" ]; then
        echo "There was a problem removing temporary file $report_unstringified_file, make sure you have correct permissions...";
        return 1;
    fi
    
    rm -f /tmp/report_stringified.txt;
    
    echo "$report_unstringified";
    return 0;
}