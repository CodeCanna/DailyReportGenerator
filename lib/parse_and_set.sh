#!/bin/bash

set -o posix;

# Import redis_connection library
source ./redis_connection.sh;

function insert_report() {
    if (! has_redis_connection) then
        create_redis_connection;
    fi

    report_name=$1; # Key
    report_content=$2 # Value;
    
    # Verify arguments
    if [[ $report_name == 0 ]] || [[ $report_content == 0 ]]; then
        echo "Expecting two arguments got $#.  ";
        echo "Arguments expected [Arg1: \$report_name, Arg2: \$report_content]";
        return 1;
    fi

    redis-cli set "$report_name" "$report_content";

    return 0;
}

function stringify_report() {
    # Get report file as an argument
    report_file=$1;

    # Stringify file contents by removing all \n and spaces
    cat $report_file | tr '\n' ';' | tr ' ' '+' > report_stringified.txt;

    report_string=$(cat ./report_stringified.txt);
    report_name=$(date +%Y-%m-%d);

    # printf "Report Content: $report_string";
    # printf "Report Name: $report_name";

    # Insert stringified report into redis
    insert_report "$report_name" "$report_string";

    return 0;
    
}

echo $(stringify_report ./test_report.txt);