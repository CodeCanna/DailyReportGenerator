#!/bin/bash

set -o posix;

source /lib/GenReport/check_redis_connection.sh;
source /lib/GenReport/redis_connection.sh;

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
    redis-cli set "$concatted_report_name" "$report_string" > /dev/null && redis-cli bgsave > /dev/null;
    if [ "$?" != 0 ]; then
        echo "There was a problem saving your reports database";
        echo "Your data is at rist of loss!";
        return 1;
    fi

    return 0;
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

    echo "$report_unstringified";
    return 0;
}