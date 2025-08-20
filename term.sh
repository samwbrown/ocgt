#!/bin/bash

PORT="20223"

trap "echo Exited!; exit;" SIGINT SIGTERM

nc -l $PORT;
