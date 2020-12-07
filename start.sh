#!/bin/bash

python /print_token.py &
mkdir -p /dev/disk/by-id

start-engine --client-console --bind-all --live-cache-type memory
