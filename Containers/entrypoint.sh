#!/bin/sh

# /opt/nessus/sbin/nessusd --no-root

_term() {
    echo "Caught SIGTERM signal! Shutting down Nessus.."
    /opt/nessus/sbin/nessusd stop
    wait "$child_pid"
    exit 0
}

# sleep 5
#
trap _term SIGTERM

/opt/nessus/sbin/nessusd --no-root &
child_pid=$!

# LOG_FILE="/opt/nessus/var/nessus/logs/nessusd.messages"
#

# while [ ! -f "${LOG_FILE}" ]; do
#     echo "Waiting for nessus log file to be created"
#     sleep 2
# done
#
# tail -f "${LOG_FILE}"
#
while true; do
    if ! kill -0 "$child_pid" >/dev/null 2>&1; then
        echo "Nessus daemon (PID $child_pid) has stopped. Restarting..."
        /opt/nessus/sbin/nessusd --no-root &
        child_pid=$!
    fi
    sleep 5
done
