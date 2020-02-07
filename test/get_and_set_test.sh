#!/bin/bash

set -o posix

# Import set library
source ../lib/set.sh;

function test_set_and_get() {
    ## Start Test ##
    
    # Get date for file naming
    DATE=$(date +%Y-%m-%d);
    
    # Set test values
    test_value='This is a test.';
    test_key='set_test';
    
    # Create test report input file
    echo "$test_value" > "/tmp/test_value_file.txt";
    
    test_value_file="/tmp/test_value_file.txt";
    
    # Set test report
    set_report "$test_key" "$test_value_file";
    
    rm -f "/tmp/test_value_file.txt";
    
    # Remember get_report gets a stringified report from redis that we have to pass to the unstringify function!
    value_to_test_stringified=$(get_report "$test_key"'_'"$DATE");
    
    value_to_test_unstringified=$(unstringify_report "$value_to_test_stringified");
    
    if [ "$value_to_test_unstringified" != "$test_value" ]; then
        echo "set_test: FAILED!";
        return 1;
    fi

    # Delete test report
    gen-report -d "$test_key"'_'"$DATE";
    if [ "$?" != 0 ]; then
        echo "Problem removing test report from Redis...";
        return 1;
    fi
    
    echo "set_test: PASSED!";
    return 0;
}
