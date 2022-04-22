# profile_lvm

![pdk-validate](https://github.com/ncsa/puppet-profile_lvm/workflows/pdk-validate/badge.svg)
![yamllint](https://github.com/ncsa/puppet-profile_lvm/workflows/yamllint/badge.svg)

NCSA Common Puppet Profiles - install and configure LVM


## Table of Contents

1. [Description](#description)
1. [Setup](#setup)
1. [Usage](#usage)
1. [Dependencies](#dependencies)
1. [Reference](#reference)


## Description

This puppet profile installs LVM software and configures LVs on a node.

It sets NCSA-defaults for certain configs.

It generally assumes you will set up PVs and VGs manually but they could
be configured with the underlying lvm Puppet module.


## Setup

Include profile_lvm in a puppet profile file:
```
include ::profile_lvm
```


## Usage

Define LVs (logical volumes) using the lvs param, which takes raw data
in the format that the lvm module expects. For example:
```
profile_lvm::lvs:
  "slurm":
    mountpath: "/slurm"
    size: "100G"
    size_is_minsize: true
    volume_group: "data"
```

Optionally define non-standard required packages or a custom default
filesystem type:
```
profile_lvm::default_fs_type: "ext4"
profile_lvm::required_pkgs:
  - "lvm2"
  - "lvm2-devel"
```

Optionally define bindmounts from LVs (or sub-directories contained in
LVs):
```
profile_lvm::bindmounts::map:
  "/var/log/slurm":
    src_lv: "slurm"
    src_path: "/slurm/log"
  "/var/spool/slurmctld.state":
    src_lv: "slurm"
    src_path: "/slurm/slurmctld.state"
```


## Dependencies

[puppet/lvm](https://github.com/ncsa/puppet-lvm) (assumes use of this NCSA fork)


## Reference

See: [REFERENCE.md](REFERENCE.md)
