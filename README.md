## Introduction
This is a puppet module that download, install, and configures BOSCO.

This is primarily intended for installations of BOSCO where SysAdmins would
like to run a separate condor collector/negotiator pair for each group flocking
into their environment. This bring a number of advantages to the table:

1. Flocking from a remote HTCondor pool into HTCondor/LSF/SGE/PBS/SLURM
2. Fine-grained control for each remote cluster / group that flocks into an environment. E.g., security settings, job wrappers, firewall negotiation.
3. A lightweight layer on top of the current configuration in the case of HTCondor-to-HTCondor submission
4. Use of shared port daemon means that clusters flocking in will need to only open one port to one host.

This is currently being used at the ATLAS Midwest Tier 2 center for backfilling
the HTCondor cluster at MWT2 with jobs from ATLAS Tier 3 clusters. Users at 
Tier 3 centers can easily acquire 500+ CPUs without ever leaving their home 
environment.

## Usage
> bosco::gatekeeper {"uc" : bosco_port => 11000, remote_schedd => 'uct3-schedd.uchicago.edu', local_schedd => 'uct2-gatekeeper.mwt2.org'}

## Potential pitfalls
This puppet module assumes that you have host-based authentication set up
between the BOSCO server and the local Condor schedd that jobs will be 
submitted to.
