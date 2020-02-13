#!/bin/bash

set -o posix;

function test_edit_and_delete() {
    local DATE=$(date +%Y-%m-%d);
    # Define key
    local key="test";
    local value="Report Content";

    # Set test value
    set_report "$key" "$value";

    # Confirm entry
    local test_entry=$(redis-cli get "$key");

    # Make sure entry was set and retrieved correctly
    if [ "$test_entry" != "$value" ]; then
        echo "Entry retrieved does not match the test entry...";
        return 1;
    fi

    

}