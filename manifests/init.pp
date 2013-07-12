### BOSCO Gatekeeper Module ###
### -L.B. 09-Jul-2013

# Install BOSCO
define bosco::gatekeeper($org = $title, $bosco_port, $remote_schedd, $local_schedd) {
  # Home directory structure local to MWT2
  $install_prefix = "/home/tier3/$org"
  $bosco_username = "tier3.$org"
  $bosco_groupname = "t3opp"
  
  # Download and install Bosco
  exec { "${title}-boscoinstaller":
    user     => "$bosco_username", # tier.[user] notation local to MWT2
    path     => '/usr/bin:/bin:/usr/sbin:/sbin',
    command  => "/bin/bash -c 'cd $install_prefix; wget ftp://ftp.cs.wisc.edu/condor/bosco/1.2/boscoinstaller; chmod +x boscoinstaller; ./boscoinstaller --prefix=$install_prefix/bosco'",
    unless   => "test -d $install_prefix/bosco",
  }
 
  # This file contains overrides to BOSCO's condor configuration to release the
  # security settings just enough to allow flocking using ClaimToBe
  file { "$install_prefix/bosco/local.${::hostname}/config/condor_config.override": 
    source  => "puppet:///modules/bosco/condor_config.override",
    owner   => "$bosco_username",
    group   => "$bosco_groupname", # statically defined for MWT2
    mode    => 644,
    require => Exec["${title}-boscoinstaller"], 
  }
 
  # This file contains a couple of values we define dynamically based on the  
  # variables passed to this class. Currently only accepts host in FLOCK_FROM
  # File format:  
  #  BOSCO_PORT = 11000
  #  FLOCK_FROM = uct3-schedd.uchicago.edu
  #  ALLOW_ADVERTISE_SCHEDD = */$(FLOCK_FROM) $(FULL_HOSTNAME) $(IP_ADDRESS)
  file { "$install_prefix/bosco/local.${::hostname}/config/condor_config.local.bosco": 
    content => "BOSCO_PORT = $bosco_port \nFLOCK_FROM = $remote_schedd\nALLOW_ADVERTISE_SCHEDD = */$(FLOCK_FROM) $(FULL_HOSTNAME) $(IP_ADDRESS)",
    owner  => "$bosco_username",
    group  => "$bosco_groupname",
    mode   => 644,
    require => Exec["${title}-boscoinstaller"],
  }

  # bosco_cluster add the remote schedd. Please update to take any # of schedds!
  # Ought to be able to change 'condor' in the command line to any scheduler
  # supported by BOSCO and get condor -> {lsf,sge,pbs,slurm} support for free.
  exec { "${title}-boscoaddcluster":
    user     => "$bosco_username",
    path     => '/usr/bin:/bin:/usr/sbin:/sbin',
    provider => shell,
    command  => "/bin/bash -c 'export HOME=$install_prefix; source $install_prefix/bosco/bosco.sh; $install_prefix/bosco/bin/bosco_cluster --add $local_schedd condor'",
    unless   => "test -d $install_prefix/.bosco", # note the ~/.bosco vs ~/bosco
    require  => Exec["${title}-boscoinstaller"],
  }

  # Inject the accounting group into the job. By default is group_bosco.<user>
  file { "$install_prefix/bosco/glite/bin/condor_local_submit_attributes.sh":
    owner   => "$bosco_username",
    group   => "$bosco_groupname",
    mode    => 755,
    content => "#!/bin/sh \necho \"+AccountingGroup = \\\"group_bosco.$bosco_username\\\"\"",
    require => Exec["${title}-boscoaddcluster"],
  }

  # Start the BOSCO service
  exec { "${title}-boscostart":
    user     => "$bosco_username",
    path     => '/usr/bin:/bin:/usr/sbin:/sbin',
    provider => shell,
    command  => "/bin/bash -c 'source $install_prefix/bosco/bosco.sh; $install_prefix/bosco/bin/bosco_start'" ,
    require  => Exec["${title}-boscoaddcluster"],
    unless   => "pgrep -f '$bosco_port'"  # Only run if condor:port isnt in ps
  } 
}
