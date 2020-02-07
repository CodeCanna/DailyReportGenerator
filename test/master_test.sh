#!/bin/bash

set -o posix;

# Import tests
source ./redis_connection_test.sh;
source ./get_and_set_test.sh;

test_redis_connection;
if [ "$?" != 0 ]; then
    echo "master_test: FAILED!";
    exit 1;
fi

test_set_and_get;
if [ "$?" != 0 ]; then
    echo "master_test: FAILED!";
    exit 1;
fi

echo "master_test: PASSED!";

sleep 2;

echo "All Tests Passed!";