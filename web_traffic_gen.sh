#!/bin/bash

while [ 1 ]; do
	echo Querying web server...
	curl 5.6.7.8 &> /dev/null &
	sleep 1
done
