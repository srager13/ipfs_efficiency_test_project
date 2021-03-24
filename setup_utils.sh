#!/bin/bash 

create_docker_containers() {
    if [ $# -ne 1 ]; then
        echo "USAGE: create_docker_containers num_nodes"
        return 1
    fi
    num_nodes=${1}
    for i in `seq 1 ${num_nodes}`; do

        echo "Setting up node $i"

        staging_dir=node${i}_staging
        data_dir=node${i}_data
        # Make local directories to import/export files to the docker containers
        mkdir -p $staging_dir
        mkdir -p $data_dir

        # Expose different port to each docker container for IPFS
        ipfs_port1=$((4000+$i))
        ipfs_port2=$((5000+$i))
        ipfs_port3=$((8080+$i))

        echo "Creating IPFS docker container with port $ipfs_port1"
        docker run -d --name ipfs_host${i} \
            -v `pwd`/$staging_dir:/export \
            -v `pwd`/$data_dir:/data/ipfs \
            -p ${ipfs_port1}:${ipfs_port1} \
            -p ${ipfs_port1}:${ipfs_port1}/udp \
            -p 127.0.0.1:${ipfs_port3}:${ipfs_port3} \
            -p 127.0.0.1:${ipfs_port2}:${ipfs_port2} \
            ipfs/go-ipfs:latest

        sleep 2
        # Change the IPFS port number to deconflict among docker containers all running on the same host
        echo "Changing API Port"
        docker exec ipfs_host${i} ipfs config --json Addresses.API "[\"/ip4/127.0.0.1/tcp/${ipfs_port2}\"]"
        sleep 1
        echo "Changing Gateway Port"
        docker exec ipfs_host${i} ipfs config --json Addresses.Gateway "[\"/ip4/127.0.0.1/tcp/${ipfs_port3}\"]"
        sleep 1
        echo "Changing Swarm Ports"
        docker exec ipfs_host${i} ipfs config --json Addresses.Swarm "[\"/ip4/0.0.0.0/tcp/${ipfs_port1}\", \"/ip6/::/tcp/${ipfs_port1}\", \"/ip4/0.0.0.0/udp/${ipfs_port1}/quic\", \"/ip6/::/udp/${ipfs_port1}/quic\"]"
        sleep 1

        # restart docker container to restart ipfs daemon
        docker stop ipfs_host${i} > /dev/null
        sleep 1
        docker start ipfs_host${i} > /dev/null
        sleep 1

        echo "IPFS Node $i container with ports $ipfs_port1, $ipfs_port2, and $ipfs_port3 successfully created"
        echo ""
    done
}

create_files_and_add_to_ipfs() {
    if [ $# -lt 1 ]; then
        echo "USAGE: create_files_and_add_to_ipfs filesize1 filesize2 ..."
        return 1
    fi

    # Count how many nodes exist
    num_nodes=`docker container ls | grep -c ipfs_host`

    ipfs_hashes_file=ipfs_hashes.txt

    echo "Creating data files, adding to IPFS, and storing hashes in ipfs_hashes.txt"
    # Make files with random data and add to IPFS, storing metadata of hashes, filenames, and number providers in a file
    # Delete stored hashes file, if it exists, to start fresh
    rm -rf $ipfs_hashes_file
    # Create sets of files with one of each size for the following categories:
    #   - one provider
    #   - num_nodes/2 providers
    for num_providers in 1 $(($num_nodes / 2)); do
        for file_size in "$@"; do
            filename=size_${file_size}_${num_providers}_providers
            dd if=/dev/urandom bs=$file_size count=1 2> /dev/null | base64 > $filename
            for p in `seq 1 ${num_providers}`; do
                cp $filename ./node${p}_staging/
                ipfs_add_result=`docker exec ipfs_host${p} ipfs add /export/$filename`
                echo " "
                echo "    Created $filename with $file_size of random data, copied to ipfs_host${p}, added to ipfs ($ipfs_add_result)"
            done
            hash_filename=`echo $ipfs_add_result | sed 's/added //g'`
            echo "$hash_filename $num_providers"  >> $ipfs_hashes_file
            rm $filename
        done
    done
}
