#!/bin/bash

set -o posix

# Import set library
source ../lib/set.sh;

## Test set_report() ##
function test_set_report() {
    # Get date for file naming
    local DATE=$(date +%Y-%m-%d);

    test='test';
    value='value';

    # Set test value
    set_report "$test" "$value";
    if [ "$?" != 0 ]; then
        echo "set_report: FAILED";
        echo "Error code $?";
    fi
    
    # Get test value
    redis-cli get "test_$DATE";
    
    if [ "$value" != 'value' ]; then
        echo "set_report: FAILED;";
        echo "Error code $?";
    fi

    redis-cli del "test_$DATE";
    
    echo "set_report: PASSED";
}

test_set_report;

