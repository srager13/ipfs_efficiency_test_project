#!/bin/bash

# Functions are in utils file to support executing them manually for testing/debugging
source setup_utils.sh

num_nodes=10
file_sizes="1m 5m 10m"

# First, create the docker containers
create_docker_containers $num_nodes
# Next, create the files and add them to the data directories
create_files_and_add_to_ipfs $file_sizes

