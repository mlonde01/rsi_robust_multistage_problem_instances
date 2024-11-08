# Instances for Robust Multistage Root Sequence Index (RSI) Allocation Problem

This project contains instances (test cases) for the Robust Multistage Root Sequence Index (RSI) Allocation Problem, an extension of the RSI Allocation Problem in 5G networks.

## ✒️ License and Citing

This project uses a permissive BSD-like license and it can be used as it pleases you. And since this framework is also part of an academic effort, we kindly ask you to remember to cite the originating paper of this work. Indeed, Clause 4 estipulates that "all publications, softwares, or any other materials mentioning features or use of this software (as a whole package or any parts of it) and/or the data used to test it must cite the following article explicitly":

    M. Londe, C.E. Andrade, L.S. Pessoa. A multi-stage approach for Root Sequence Index allocation. 

Check it out the full license.

## 📚 Instances

The multistage RSI instances are divided into two large groups:

    Monthly: for these instances, we consider that the instance spans a year and changes in network topology happen each month, with 12 stages analyzed;
    Seasonal: in these instances, there are 4 stages, indicating that changes happen after 3 months;

The instances are further divided in long and short preambles. The instance preamble indicates the minimum and maximum possible values for the RSI.

The naming convention is the following: <preamble>_n<number of nodes>_r<mininum RSI distance>_<maximum RSI distance>_s<number of stages>_t<number of scenarios per stage>_g<value of Gamma>_d<value of Delta>.txt. For example, long_n0030_r030_150_s4_t30_g50_d40.txt indicates a long preamble instance with 30 nodes such that the minimum allowed RSI distance is 30 and the maximum allowed RSI distance is 150, considering 4 stages with 30 scenarios per stage, Gamma of 50\% and Delta of 40\%. 

All instances have the following fields:

    instance_name: a string with the instance name;
    istance_group: either "long" or "short" preamble;
    rsi_range: two positive integers indicating the range from where RSIs should be pulled;
    rsi_min_max_distance: the minimal and maximal RSI distance allowed between neighboring cells. Note that is rsi_max_distance is equal to 139 (for short preambles) or 839 (for long preambles), we have no maximal distance;
    num_nodes: number of nodes or radios in the network;
    original_rsis: the original RSIs assigned to these nodes;
    num_neighbors: number of edges between the nodes;
    neighbors: a num_neighbors X 2 matrix that indicates each edge of the neighboring graph;
    gamma: float value indicating the amount of percentual changes in network topology between stages;
    delta: float value indicating the chance of increase or decrease in density between stages;
    num_stages: number of stages considered;
    num_trajectories: number of scenarios per stage observed;
    scenarios: a num_nodes X num_nodes X num_stages X num_trajectories matrix that indicates the existing edges in each stage and scenario. A 1 indicate the existence of an edge, while a 0 means it does not exist.

The files are in plain text (.txt) for easy parsing.

## :computer: Instance generator code

The Julia code used to create the instances is included in this project. It has the following parameters

    <rsi-instance-file> : the original RSI allocation problem instance file. Those instances may be found in https://github.com/ceandrade/rsi_allocation_problem_instances;
    <seed> : random seed value;
    <number-stages> : desired number of stages;
    <number-scenarios> : desired number of scenarios per stage;
    <gamma> : desired value of gamma for the scenarios;
    <delta> : desired value of delta for the scenarios;
    <new_inst_dir>: directory where the new instance will be saved.

The code includes a two structs rsiInstance and ms_rsiInstance, which are used to propoerly initialize and read the files.
