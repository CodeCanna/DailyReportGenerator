#!/bin/bash

set -o posix;

function create_redis_connection() {
    if (! do_connect) then
        echo "This program needs Redis to be running.  Exiting!";
        exit 1;
    fi

    # Start a redis instance
    if (! systemctl start redis) then
        echo "There was a problem starting redis!"\
        "Try running 'systemctl status redis' to see why Redis failed to start."\
        "This is a Fatal Error, Exiting" >&2;
        # Return failure code
        return 1;
    fi

    # Give time for redis to start
    sleep 0.5;
    
    echo "Redis Started Sucessfully!";
    return 0;
}

function destroy_redis_connection() {
    if (! do_disconnect) then
        return 1;
    fi

    # Stop redis instance and test that it's down
    systemctl stop redis && redis_is_down=$(redis-cli ping);
    if [[ "$?" != 0 ]] && [[ $redis_is_down == 'PONG' ]]; then
        echo "REDIS DID NOT SHUT DOWN PROPERLY!!!";
        echo "YOU MAY HAVE LOST DATA!!!";
        echo "CHECK YOUR REDIS INSTALL AND FILES RIGHT AWAY!!!";
        echo "CRASHING AND BURNING...";
        exit 128;
    fi

    echo "Redis shut down successfully, connection closed.";
    return 0;
}

function do_connect() {
    while true; do
        read -p "Would you like to connect to Redis? [Y, N] " choice;
        
        case $choice in
            'Y' | 'y')
                return 0;
            ;;
            'N' | 'n')
                return 1;
            ;;
            *)
                echo "Invalid option press the Y or the N key.";
        esac
    done
}

function do_disconnect() {
    while true; do
        read -p "Are you sure you want to disconnect from Redis?  This will close your connection to Redis and stop the Redis service! [Y, N]" choice;
        
        case $choice in
            'Y' | 'y')
                return 0;
            ;;
            'N' | 'n')
                return 1;
            ;;
            *)
                echo "Invalid option press the Y or the N key.";
        esac
    done
}