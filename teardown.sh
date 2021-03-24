#!/bin/bash

# Stop containers, if necessary
for node in `docker container ls | grep ipfs_host | awk '{print $NF}'`; do
    echo "Stopping $node"
    docker stop $node
done

# Remove containers
for node in `docker container ls -a | grep ipfs_host | awk '{print $NF}'`; do
    echo "Removing $node"
    docker rm $node > /dev/null

    node_num=`echo $node | sed 's/ipfs_host//g'`
    rm -rf node${node_num}_data
    rm -rf node${node_num}_staging
done
