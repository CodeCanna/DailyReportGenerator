#!/bin/bash

set -o posix;

# Import /lib/redis_connection.sh
source ../lib/redis_connection.sh;

# Check if connected to redis
if (! has_redis_connection) then
    # If NOT connected to redis ask to connect
    create_redis_connection;
    if [ "$?" != 0 ]; then
        echo "Test Failed: Couldn't Connect to Redis...";
        exit 1;
    fi

    echo "** Test passed! You should be able to connect to Redis! **";
    exit 0;
fi

# If connected to redis
if (has_redis_connection) then
    # Disconnect from redis
    destroy_redis_connection;
    if [ "$?" != 0 ]; then
        echo "Test Failed: Couldn't shut Redis down properly, this is not good...";
        exit 1;
    fi

    echo "** Test Passed! Successfully Disconnected from Redis! **";
    exit 0;
fi

