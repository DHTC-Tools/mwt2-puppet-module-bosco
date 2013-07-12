This is a puppet module that download, install, and configures BOSCO.

This is primarily intended for installations of BOSCO where SysAdmins would
like to run a separate condor collector/negotiator pair for each group flocking
into their environment. There are a number of advantages here:
  1) Flocking from a remote HTCondor pool into HTCondor/LSF/SGE/PBS/SLURM
  2) Fine-grained control for each remote cluster / group that flocks into an
     environment. E.g., security settings, job wrappers, firewall negotiation.
  3) A lightweight layer on top of the current configuration in the case of
     HTCondor-to-HTCondor submission
  4) Use of shared port daemon means that clusters flocking in will need to
     only open one port to one host.

This is currently being used at the ATLAS Midwest Tier 2 center for backfilling
the Tier 2 with jobs from ATLAS Tier 3 clusters. Users at the Tier 3 can easily
get 500+ CPUs without ever leaving their home environment.
