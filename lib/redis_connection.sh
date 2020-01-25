#!/bin/bash

set -o posix;

# Is current user root?
function is_root() {
    if [ "$USER" != 'root' ]; then
        # Not root return error
        return 1;
    fi
    # Root return OK
    return 0;
}

function create_redis_connection() {
    # Start a redis instance
    systemctl start redis;
    if [ "$?" != 0 ]; then
        echo "There was a problem starting redis!";
        echo "Try running 'systemctl status redis' to see why Redis failed to start.";
        echo "This is a Fatal Error, Exiting";
        exit "$?";
    fi

    echo "Redis Started Sucessfully!";
    return 0;
}

function destroy_redis_connection() {
    # Stop redis instance
    systemctl stop redis;
    if [ "$?" != 0 ]; then
        echo "REDIS DID NOT SHUT DOWN PROPERLY!!!";
        echo "YOU MAY HAVE LOST DATA!!!";
        echo "CHECK YOUR REDIS INSTALL AND FILES RIGHT AWAY!!!";
        echo "CRASHING AND BURNING...";
        exit 1;
    fi

    echo "Redis shut down successfully, connection closed.";
}

function do_reconnect() {
    while true; do
        read -p "Would you like to try reconnecting to Redis? [Y, N]" choice;

        case $choice in
            'Y' | 'y')
                return 0;
            ;;
            'N' | 'n')
                return 1;
            ;;
            *)
                echo "Invalid option press the Y or the N key."
        esac
    done
}

# Checks the connection to Redis
function has_redis_connection() {
    # Ping redis server
    redis-cli ping;
    if [ "$?" != 0 ]; then
        echo "Make sure Redis is started/enabled by your init system...";
        echo "Try running 'sudo systemctl status redis' to check the status of Redis.";
        echo "If the process is not running type 'sudo systemctl start redis' to start the redis daemon.";
        echo "Otherwise try consulting the Redis docs at https://redis.io/documentation";
        return 1;
    fi

    return 0
}

# Make sure script runs as root.
if [ "$USER" != 'root' ]; then
    echo "This script must be ran as root. [redis_connection.sh]";
    exit 1;
fi