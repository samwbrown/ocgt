#!/bin/bash

file=$1
PORT="20222"

echo Serving $file...

trap "echo Exited!; exit;" SIGINT SIGTERM

while true; do 
    cat $file | timeout 0.5 nc -l $PORT;

    retVal=$?
    if [ $retVal -eq 0 ]; then
        continue;
        # echo Served $file at $(date "+%H:%M:%S");
    elif [ $retVal -ne 124 ]; then
        exit $retVal;
    fi
done
