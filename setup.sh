#!/bin/bash

num_nodes=2
file_sizes=(1m 25m 50m 100m)

for i in `seq 1 ${num_nodes}`; do

    echo "Setting up node $i"

    staging_dir=node${i}_staging
    data_dir=node${i}_data
    # Make local directories to import/export files to the docker containers
    mkdir -p $staging_dir
    mkdir -p $data_dir

    # Expose different port to each docker container for IPFS
    ipfs_port=$((4000+$i))

    echo "Creating IPFS docker container with port $ipfs_port"
    docker run -d --name ipfs_host${i} \
        -v `pwd`/$staging_dir:/export \
        -v `pwd`/$data_dir:/data/ipfs \
        -p ${ipfs_port}:${ipfs_port} \
        -p ${ipfs_port}:${ipfs_port}/udp \
        ipfs/go-ipfs:latest
        #-p 127.0.0.1:8080:8080 \
        #-p 127.0.0.1:5001:5001 \

    sleep 1
    # Change the IPFS port number to deconflict among docker containers all running on the same host
    docker exec ipfs_host${i} ipfs config --json Addresses.Swarm "[\"/ip4/0.0.0.0/tcp/${ipfs_port}\", \"/ip6/::/tcp/${ipfs_port}\", \"/ip4/0.0.0.0/udp/${ipfs_port}/quic\", \"/ip6/::/udp/${ipfs_port}/quic\"]"

    # restart docker container to restart ipfs daemon
    docker stop ipfs_host${i} > /dev/null
    sleep 1
    docker start ipfs_host${i} > /dev/null
    sleep 1

    echo "IPFS Node $i container with port $ipfs_port successfully created"

    echo "Creating data files, adding to IPFS, and storing hashes in ipfs_hashes.txt"
    # Make files with random data and add to IPFS
    pushd $staging_dir > /dev/null
    # Delete stored hashes file, if it exists, to start fresh
    rm -rf ipfs_hashes
    for file_size in ${file_sizes[@]}; do
        filename=node${i}_size_${file_size}
        dd if=/dev/urandom of=$filename bs=$file_size count=1 2> /dev/null
        ipfs_add_result=`docker exec ipfs_host${i} ipfs add /export/$filename`
        echo "    Created $filename with $file_size of random data, added to ipfs ($ipfs_add_result)"
        echo $ipfs_add_result | sed 's/added //g'  >> ipfs_hashes
    done
    popd > /dev/null

    echo ""
done
