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
source /lib/GenReport/test/redis_connection_test.sh;
source /lib/GenReport/test/get_and_set_test.sh;

# Run the Redis connection test
if (! test_redis_connection) then
    echo "master_test: FAIL!";  # Echo Failed results
    exit 1;
fi

echo "redis_connection_test: PASS!";

# Run the set and get test
if (! test_set_and_get) then
    echo "master_test: FAIL!";  # Echo Failed results
    exit 1;
fi

echo "get_and_set_test: PASS!";

# Echo passing results
echo "master_test: PASS!";
echo "All Tests Passed!";