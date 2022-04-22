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

This puppet profile installs LVM software and configures PVs, VGs, and LVs on a node.

Uses pre-existing lvm Puppet module.


## Setup

Include profile_lvm in a puppet profile file:
```
include ::profile_lvm
```


## Usage

TBD

## Dependencies

puppet/lvm (assumes use of NCSA fork)


## Reference

See: [REFERENCE.md](REFERENCE.md)
