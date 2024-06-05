# @summary Create bindmounts from (within) LVs on a directory
#
# @param map
#   mapping of bindmounts from LVs and their paths/sub-directories
#
#   Example hiera parameter:
# ```
#   profile_lvm::bindmounts::map:
#     "/var/spool/slurmctld.state":
#       #opts: "defaults,bind,noauto,ro"
#       src_lv: "slurm"
#       src_path: "/slurm/slurmctld.state"
# ```
#
# @example
#   include profile_lvm::bindmounts
class profile_lvm::bindmounts (
  Optional[Hash] $map = undef,
) {
  if $map {
    $map.each | $k, $v | {
      profile_lvm::bindmount_resource { $k: * => $v }
    }
  }
}
