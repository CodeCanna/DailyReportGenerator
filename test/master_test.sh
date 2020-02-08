#!/bin/bash

set -o posix;

# Check GenReport installation
if [ ! -f /bin/gen-report ]; then
    echo "GenReport install not found...";
    echo "To try running the installer again:";
    echo "Run [cd /path/to/gen-report/download/], then run [sudo ./install.sh] to try running the installer again.";
    exit 1;
fi

# Import tests
source ./redis_connection_test.sh;
source ./get_and_set_test.sh;

# Run the Redis connection test
test_redis_connection;
if [ "$?" != 0 ]; then
    echo "master_test: FAIL!";  # Echo Failed results
    exit 1;
fi

echo "redis_connection_test: PASS!";

# Run the set and get test
test_set_and_get;
if [ "$?" != 0 ]; then
    echo "master_test: FAIL!";  # Echo Failed results
    exit 1;
fi

echo "get_and_set_test: PASS!";

# Echo passing results
echo "master_test: PASS!";
echo "All Tests Passed!";