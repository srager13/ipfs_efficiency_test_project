#!/bin/bash
source experiment_utils.sh

experiment_data_dir="$(date +"latency_experiment_%m_%d_%y_%I_%M_%p")"
mkdir $experiment_data_dir
experiment_data_file=${experiment_data_dir}/latency_experiment_results.log
echo "Experiment data file: $experiment_data_file"
# Add header line to the data file
echo "Number_Providers,Number_Fetchers,Filesize,Download_Time" > $experiment_data_file

get_num_nodes    
num_nodes=$?

# Start docker containers, if necessary
if [ `docker container ls | grep ipfs_host | wc -l` -ne $num_nodes ]; then
    for i in `seq 1 ${num_nodes}`; do
        docker start ipfs_host${i} 
    done
fi


# Test 1: one provider - one fetcher
run_experiment 1 1 $experiment_data_file

# Test 2: one provider - many fetchers
run_experiment 1 9 $experiment_data_file

# Test 3: many provider - many fetchers
run_experiment 5 5 $experiment_data_file
