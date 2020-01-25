#!/bin/bash

set -o posix;

# Prints current error
function echoerr() {
    printf "%s\n" "$*" >&2;
}

# Checks the connection to Redis
function test_redis_connection() {
    redis-cli ping;
    if [ "$?" != 0 ]; then
        echo "Make sure Redis is started/enabled by your init system...";
        echo "Try running 'sudo systemctl status redis' to check the status of Redis.";
        echo "If the process is not running type 'sudo systemctl start redis' to start the redis daemon.";
        echo "Otherwise try consulting the Redis docs at https://redis.io/documentation";
        exit "$?";
    fi
}

function insert_report() {
    report_name=$1;
    report_content=$2;
    
    # Verify arguments
    if [[ $report_name != 0 ]] || [[ $report_content != 0 ]]; then
        echo "Expecting two arguments got $#";
        echo "Arguments expected [Arg1: \$report_name, Arg2: \$report_content]";
        exit 1;
    fi



    exit 0;
}

function parse_report() {
    report_file=$1;

    # Remove bloat
    sed -e 's/-//g'\
        -e 's/#//g'\
        -e 's/^ //g'\
        -e '/^$/d'\
        -e '' $report_file > new_file.txt;

    #rm -rf $report_file;
    
}

parse_report ./test_report.txt