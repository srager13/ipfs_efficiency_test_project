#!/bin/bash 
# Find the number of ipfs_host docker containers on this machine
get_num_nodes() {
    return `docker container ls -a | grep ipfs_host | wc -l`
}

download_file_and_record_time() {
    if [ $# -lt 3 ]; then
        echo "USAGE: download_file_and_record_time hash filename experiment_data_file"
        return 1
    fi

    hash=$1
    filename=$2
    fetcher=$3
    experiment_data_file=$4
    num_providers=$5
    num_fetchers=$6

    # Get filesize
    filesize=`ls -l ./node1_staging/${filename} | awk '{print $5}'`

    # Retrieve files stored in node 1
    download_time=`{ time -p docker exec ${fetcher} ipfs get -o ./export/ $hash ; } 2>&1 | grep real | awk '{print $2}'`

    # Write data points to a file to analyze/plot later
    # Colummns: num providers, num fetchers, filesize, download time
    echo "$num_providers, $num_fetchers, $filesize, $download_time"
    echo "$num_providers,$num_fetchers,$filesize,$download_time" >> $experiment_data_file
}

run_experiment() {
    if [ $# -lt 2 ]; then
        echo "USAGE: run_experiment num_providers num_fetchers experiment_data_file"
        return 1
    fi

    num_providers=$1
    num_fetchers=$2
    experiment_data_file=$3

    echo " "
    echo "RUNNING EXPERIMENT: $num_providers providers, $num_fetchers fetchers"
    echo " "
    echo " "

    # find the number of nodes by counting docker containers
    get_num_nodes    
    num_nodes=$?

    echo "Total number of nodes = $num_nodes"

    while read line; do
        # each line has format "hash filename num_providers" so break it up into two variables:
        fields=($line)
        hash=${fields[0]}
        filename=${fields[1]}
        file_num_providers=${fields[2]}

        # only download the files that have the correct number of providers. skip the others
        if [ $file_num_providers -ne $num_providers ]; then
            continue
        fi

        # Loop through nodes starting from highest node id to initiate num fetchers 
        for f in `seq $num_nodes $(($num_nodes-$num_fetchers+1))`; do 
            echo "ipfs_host${f} downloading file $filename"
            download_file_and_record_time $hash $filename ipfs_host${f} $experiment_data_file $num_providers $num_fetchers &
        done

        # wait for all of the downloads to complete
        wait

    done <./ipfs_hashes.txt
}

