#!/bin/bash

set -o posix;

# Import redis_connection library
source "/lib/GenReport/lib/redis_connection.sh";

function insert_report() {
    # Check for redis connection and if no connection is found then make one
    if (! has_redis_connection) then
        echo "Who?";
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

    if [ -z $report_content ]; then
        echo "Something went wrong with inserting report."
        echo "Report content given: $2";
        echo "Report content: $report_content";

        exit 1;
    fi

    local report_string=$(stringify_report "$report_content");

    redis-cli set "$concatted_report_name" "$report_string";
    return 0;
}

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