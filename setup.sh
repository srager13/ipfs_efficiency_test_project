#!/bin/bash

# Functions are in utils file to support executing them manually for testing/debugging
source setup_utils.sh

num_nodes=4
file_sizes="1k 2k 3k"
#file_sizes="1m 25m 50m 100m"

# First, create the docker containers
create_docker_containers $num_nodes
# Next, create the files and add them to the data directories
create_files_and_add_to_ipfs $file_sizes

