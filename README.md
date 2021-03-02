# IPFS Efficiency Test Project

This project is designed to test the efficiency of the IPFS Block Transfer protocol (bitswap). It works by creating a specified number of docker containers, each running IPFS. The nodes will create and add files of various size to IPFS and then run a series of experiments fetching those files, tracking the latency of download times for each experiment. 

## Requirements

Docker (tested on 20.10.2) - Download and install from: https://docs.docker.com/get-docker/

This project was created on Mac OS Mojave Version 10.14.6 and has not been tested on any other platforms.

## Setup

Running the setup.sh script will create and configure the docker containers. It will also create directories that will be mapped to the docker containers and files of varying size in these directories to run the file transfer experiments with. By default, setup.sh will create 10 container nodes and files ranging in size from 10MB to 100MB. To change these default settings, edit the variables declared at the top of setup.sh.

## Running experiments

Execute the run_experiments.sh script to run the experiments of transferring files using IPFS and bitswap. By default, the experiments run are:
  - 1 provider, 1 fetcher
  - 1 provider, 9 fetchers
  - 5 provider, 5 fetchers

Each of these experiments is run for file sizes of 10MB, 25MB, 50MB, and 100MB, using IPFS and then bitswap. Latency results are stored in the export directory in the docker container, which is mapped to a docker_ipfs_staging folder for each node.

## Plotting results

TODO

## Teardown

After you are finished running the experiments, you can run teardown.sh to delete the docker containers, files, and directories created by setup.sh.


