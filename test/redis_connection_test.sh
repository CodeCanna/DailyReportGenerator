#!/bin/bash

set -o posix;

# Import /lib/redis_connection.sh
source ../lib/redis_connection.sh;

# Check if connected to redis
if (! has_redis_connection) then
    # If NOT connected to redis ask to connect
    create_redis_connection;
    if [ "$?" != 0 ] && [ "$?" == 3]; then
        echo "Redis couldn't start redis correctly...";
        exit 1;
    fi

    echo "** Test passed! Successfully Connected to Redis!! **";
fi

echo "Now testing the disconnect";
sleep 2;

# If connected to redis
if (has_redis_connection) then
    # Disconnect from redis
    destroy_redis_connection;
    if [ "$?" != 0 ]; then
        echo "Keeping Redis running, you might have to either re-run this script or stop Redis youself with systemd.";
        exit 1;
    fi

    echo "** Test Passed! Successfully Disconnected from Redis!! **";
fi

exit 0;
