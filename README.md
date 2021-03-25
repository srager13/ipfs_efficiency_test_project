# IPFS Efficiency Test Project

This project is designed to test the efficiency of IPFS. It works by creating a specified number of docker containers, each running IPFS. The nodes will create and add files of various size to IPFS and then run a series of experiments fetching those files, tracking the latency of download times for each experiment. 

## Requirements

WARNING: This project was created on Mac OS Mojave Version 10.14.6 and has not been tested on any other platforms.

Docker (tested on 20.10.2) - Download and install from: https://docs.docker.com/get-docker/

The plotting script requires:
    - python >= 3.7
    - pandas 1.2.3
    - seaborn 0.11.1
    - matplotlib 3.3.4
If using conda, creating new conda environment with python >= 3.7 and installing pandas and seaborn is sufficient.
```
conda create -n ipfs_efficiency_test_project python=3.8
conda activate ipfs_efficiency_test_project
conda install pandas
conda install seaborn
```

## Setup

Running the setup.sh script will create and configure the docker containers, changing the port numbers that IPFS uses in each docker container to prevent them from overlapping if being mapped to the host's ports. It will also create directories that will be mapped to the docker containers and files of varying size in these directories to run the file transfer experiments with. 

Files:
The set of file sizes and numbers of providers to set up are specified at the top of setup.sh. This script will create a file for each (filesize, num providers) pair and copy that file to the data folders of the first num providers docker conainers. The script executes the command for each provider docker container to add their files to IPFS and store the returned hashes in a file in the local directory titled 'ipfs_hashes.txt' with the following format for each line: 
  "hash filename num_providers"

By default, setup.sh will create 10 container nodes and files of sizes 1MB, 5MB, and 10MB for 1 provider and 5 providers. To change these default settings, edit the variables declared at the top of setup.sh.

## Running experiments

Execute the run_experiments.sh script to run the experiments of transferring files using IPFS. By default, the experiments run are:
  - 1 provider, 1 fetcher
  - 1 provider, 9 fetchers
  - 5 provider, 5 fetchers

For each experiment run, the script will assign fetchers to download files of each size created in setup.sh. Since setup copies files to providers starting with the lowest node IDs, experiments start with highest node IDs and count down. For example, if we have 10 nodes and run an experiment with 5 providers and 5 fetchers, nodes 1-5 will be the providers and nodes 6-10 will be the fetchers. 

The fetchers will time how long the ipfs get command takes to finish, i.e. the download time, and output it to an output log file created for each experiment that includes a timestamp of when the experiment was run. 

## Plotting results

Plot results of the experiments with the following script, which takes two arguments: the experiment logfile and the directory to which the resulting plot should be saved. 

Example: 
```
python plot_latency_experiment_results.py ./latency_experiment_03_23_21_09_48_PM/latency_experiment_results.log ./latency_experiment_03_23_21_09_48_PM
```

## Teardown

After you are finished running the experiments, you can run teardown.sh to delete the docker containers, files, and directories created by setup.sh.


