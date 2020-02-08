#!/bin/bash

set -o posix;

# Import /lib/redis_connection.sh
source ../lib/redis_connection.sh;

function test_redis_connection() {
    # Check if connected to redis
    if (! has_redis_connection) then
        # If NOT connected to redis ask to connect
        create_redis_connection;
        if [ "$?" != 0 ] && [ "$?" == 3]; then
            return 1;
        fi
    fi
    
    # If connected to redis
    if (has_redis_connection) then
        # Disconnect from redis
        destroy_redis_connection;
        if [ "$?" != 0 ]; then
            return 1;
        fi
    fi

    return 0;
}

