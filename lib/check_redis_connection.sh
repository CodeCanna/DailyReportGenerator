#!/bin/bash

set -o posix;

# Checks the connection to Redis
function has_redis_connection() {
    # Ping redis server
    redis_pinged=$(redis-cli ping)
    if [[ $redis_pinged != 'PONG' ]]; then
        return 1; # Return error status
    fi
    
    return 0
}