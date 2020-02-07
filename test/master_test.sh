#!/bin/bash

set -o posix;

# Import tests
source ./redis_connection_test.sh;
source ./get_and_set_test.sh;

# Run the Redis connection test
test_redis_connection;
if [ "$?" != 0 ]; then
    echo "master_test: FAILED!";  # Echo Failed results
    exit 1;
fi

# Run the set and get test
test_set_and_get;
if [ "$?" != 0 ]; then
    echo "master_test: FAILED!";  # Echo Failed results
    exit 1;
fi

# Echo passing results
echo "master_test: PASSED!";
echo "All Tests Passed!";