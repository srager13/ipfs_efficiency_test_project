#!/bin/bash

# stop ipfs_host docker containers
for node in `docker container ls | grep ipfs_host | awk '{print $NF}'`; do
    echo "Stopping $node"
    docker stop $node
done
