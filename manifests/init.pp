# @summary Installs LVM software and wraps/provides defaults for the standalone lvm module.
#
# Installs LVM software and wraps/provides defaults for the standalone lvm module.
#
# @example
#   include profile_lvm
#
# @param required_pkgs
#   Names of lvm package(s (usually lvm2).
#
# @param default_fs_type
#   WARNING: default = xfs via data-in-module for this. Overrides default of ext4 from ::lvm module.
#   It would be better to not have a default (it's very dangerous, because if you don't specify the
#   fs_type and your existing LVM has a different type, it seems that it would reformat the fs. But
#   since the ::lvm module already has a default, let's override it with a better one for NCSA systems.
#
# @param lvs
#   Pre-existing lvm's that puppet should be aware of. Notice that there is no
#   mention of the PVs at all.
#   Key-value pairs used to declare ::lvm::logical_volume resources. Lookup is merge, but not deep.
#   Form:
#     keys = names of LVM resources (String)
#     values = params for LVM resources (Hash)
#
#   BE VERY CAREFUL WITH WHAT YOU PUT IN HIERA FOR THIS CLASS/PARAMETER!
#   This is especially the case for LVMs that already exist (created manually or via xCAT). To 
#   manage an existing LVM you'll generally* need to minimally specify:
#     - mountpath
#     - volume_group
#   (* Settings to configure LVM-based swap space would not include a mountpath, for instance, and
#   should specify fs_type to be 'swap'.)
#   MAKE SURE that the fs_type is/should be xfs otherwise override that as well. And be careful 
#   if you specify size. You can often grow the LVM and its filesystem but generally cannot shrink 
#   the filesystem. (The lvm module seems to error and refuse to try, which is good. But be
#   careful!)
#
#   It's intended for Hiera to do a hash merge but NOT a deep merge of the lvms param. This is
#   so we intentionally and clearly specify all required parameters at each level just to be safe.
#
#   NOTE: If you use this class to start managing an existing (definitely an xCAT-deployed) LVM
#   it will likely insist on cleaning up your mount in fstab, e.g.,:
#     Notice: /Stage[main]/Stdcfg::Lvm/Lvm::Logical_volume[LVvar]/Mount[/var]/device:
#       device changed '/dev/mapper/VGsystem-LVvar' to '/dev/VGsystem/LVvar'
#     Notice: /Stage[main]/Stdcfg::Lvm/Lvm::Logical_volume[LVvar]/Mount[/var]/pass: pass changed '0' to '2'
#   This should not cause an actual remount.
#
# @param volume_groups
#   Hash of Volume Groups with PVs to be created and LVs to be mounted.
#   These are fully created and managed by Puppet.
#   Puppet creates the PVs and VGs.
#   Example (in YAML format):
#     profile_lvm::volume_groups:
#       vg_pgsql:
#       | physical_volumes: [ "/dev/sdb" ]
#       | logical_volumes:
#       | ¦ postgres:
#       | ¦ ┆ fs_type: "xfs"
#       | ¦ ┆ mountpath: "/var/lib/pgsql"
#       vg_backups:
#       | physical_volumes: [ "/dev/sdc" ]
#       | logical_volumes:
#       | ¦ backups:
#       | ¦ ┆ fs_type: "xfs"
#       | ¦ ┆ mountpath: "/backups"
#       vg_jsm:
#       | physical_volumes: [ "/dev/sdd" ]
#       | logical_volumes:
#       | ¦ jsm:
#       | ¦ ┆ fs_type: "xfs"
#       | ¦ ┆ mountpath: "/jsm"
#   This is a workaround for the broken behavior of puppetlabs::lvm (pvs
#   passed as a hash are improperly turned into an array).
#   PVs and VGs will be created IFF they don't already exist. It is assumed that
#   See also: https://github.com/puppetlabs/puppetlabs-lvm/
class profile_lvm (

  String                $default_fs_type,
  Hash[String[1],Hash ] $lvs,
  Array                 $required_pkgs,
  Hash                  $volume_groups,

) {

  # Install LVM package(s)
  $packages_defaults = {
  }
  ensure_packages( $required_pkgs, $packages_defaults )

  # Include the LVM module
  include ::lvm

  # Include profile_lvm sub-classes
  include ::profile_lvm::bindmounts

  # Manage any LVMs defined via Hiera data
  each( $lvs ) | String[1] $key, Hash $overrides| {
    lvm::logical_volume {
      $key:
        * => $overrides,
      ;
      default:
        fs_type => $default_fs_type,
      ;
    }
  }

  
  $volume_groups.each | String[1] $vg, Hash $params | {
    # Create the physical volumes, if needed
    $pvs = $params[ 'physical_volumes' ]
    lvm::physical_volume { $pvs :
      unless_vg => $vg,
    }
    # Create the volume groups, if needed
    lvm::volume_group { $vg :
      createonly => true,
    }
    $lvs = $params[ 'logical_volumes' ]
  }
  # ensure_resources( lvm::volume, $volumes )

}
