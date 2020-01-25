#!/bin/bash

set -o posix;

# Prints current error
function echoerr() {
    printf "%s\n" "$*" >&2;
}

function insert_report() {
    report_name=$1;
    report_content=$2;
    
    # Verify arguments
    if [[ $report_name != 0 ]] || [[ $report_content != 0 ]]; then
        echo "Expecting two arguments got $#";
        echo "Arguments expected [Arg1: \$report_name, Arg2: \$report_content]";
        return 1;
    fi

    redis-cli set $report_name $report_content;


    return 0;
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