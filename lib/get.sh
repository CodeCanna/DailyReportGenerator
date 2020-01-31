#!/bin/bash

set -o posix;

# Import a library to check the redis connection
source /lib/GenReport/check_redis_connection.sh;

# Get report based on given key
function get_report() {
    # Check for redis connection and if no connection is found then make one
    if (! has_redis_connection) then
        create_redis_connection;
    fi
    
    # Get redis key to search for from args
    report_key=$1;
    
    # Check if that key exists, if it doesn't return error
    local report_key=$(redis-cli --scan --pattern "$report_key");
    if [ -z "$report_key" ]; then
        echo "Key not found...";
        return 1;
    fi

    # If the keys exists get the contents and echo it
    report=$(redis-cli get "$report_key");

    # Output result to the screen for later capture with command substitution then return
    echo "$report";
    return 0;
}

# Get all report redis keys from the database
function get_all_report_keys() {
    # Check for redis connection and if no connection is found then make one
    if (! has_redis_connection) then
        create_redis_connection;
    fi
    
    # Get all redis keys and store them in tmp
    redis-cli --scan --pattern '*' > /tmp/repkeys.txt;
    
    # Get /tmp/repkeys.txt
    repkeys=/tmp/repkeys.txt;
    
    # Create an array to store keys
    declare -ag keyarr;
    
    # Iterate through the contents of repkeys
    while read p; do
        # Add each key to an array
        keyarr+=("$p");
    done < "$repkeys"
    
    # Check if keyarr is empty
    keyarrlen=${#keyarr[*]};
    if [ "$keyarrlen" == 0 ]; then
        echo "Database empty no keys found...";
        return 1;
    fi
    
    # Remove /tmp/repkeys.txt
    rm -rf "$repkeys";

    echo "${keyarr[@]}";
    return 0;
}

# Grab the latest report from the database
function get_latest_report() {
    # Get todays date
    local date_today=$(date +%Y-%m-%d);

    # Find the date of the latest report

    # Create array containing all report redis keys
    local all_report_keys=($(get_all_report_keys));

    echo "$all_report_keys" > /tmp/keys.txt;

    sed -e 's/_//g' \
        -e 's/[a-z]//g' /tmp/keys.txt > /tmp/dates.txt;

    # Create report dates array and remove /tmp/dates.txt
    local report_dates=($(cat /tmp/dates.txt)) && rm -f /tmp/dates.txt;

    # For loop where d is date
    for d in "${report_dates[@]}"; do
        if [[ "$d" == "$date_today" ]]; then
            today_report_key=$(cat /tmp/keys.txt | grep $d);
            today_report_string=$(redis-cli get "$today_report_key");

            unstringify_report "$today_report_string";
        fi
    done
}