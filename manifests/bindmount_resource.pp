# @summary Create a bindmount from (within an) LV on a directory
#
# Assumes that we are bindmounting from an LV or sub-directory of
# an LV.
#
# @param opts
#   Mount options. MUST include 'bind'.
#
# @param src_lv
#   The LV we are bindmounting from.
#
# @param src_path
#   The location we are bindmounting from (either same as
#   mountpoint of src_lv or a sub-directory).
#
# @example
#   profile_lvm::bindmount_resource { "/var/spool/slurmctld.state":
#     #opts      => "defaults,bind,noauto,ro"
#     src_lv    => "slurm",
#     src_path  => "/slurm/slurmctld.state",
#   }
#
define profile_lvm::bindmount_resource (
  String $src_lv,
  String $src_path,
  String $opts = 'defaults,bind,noauto',
) {

  # Resource defaults
  Mount {
    ensure => mounted,
    fstype => 'none',
  }
  File {
    ensure => directory,
  }

  # Ensure parents of target dir exist, if needed (excluding / )
  $dirparts = reject( split( $name, '/' ), '^$' )
  $numparts = size( $dirparts )
  if ( $numparts > 1 ) {
    each( Integer[2,$numparts] ) |$i| {
      ensure_resource(
        'file',
        reduce( Integer[2,$i], $name ) |$memo, $val| { dirname( $memo ) },
        { 'ensure' => 'directory' }
      )
    }
  }

  # Ensure target directory exists
  ensure_resource( 'file', $name )

  # Add bind option if not already included
  if ( $opts =~ /bind/ ) {
    $mount_opts = $opts
  } else {
    $mount_opts = join( split( $opts, ',' ) + 'bind', ',' )
  }

  # Define the mount point
  mount { $name:
    device  => $src_path,
    options => $mount_opts,
    require => [
      File[ $name ],
      Lvm::Logical_volume[ $src_lv ],
    ],
  }

}
