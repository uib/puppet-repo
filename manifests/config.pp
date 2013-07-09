# Class: repo::config
#
# Set up the repos and users
#
# == Parameters
#
# == Authors
#
# Raymond Kristiansen <raymond.kristiansen@it.uib.no>
#
class repo::config(
  $basedir    = $::repo::basedir,
  $user       = $::repo::user,
  $group       = $::repo::group
) {

  $dirs = [$basedir,
          "${basedir}/yum", "${basedir}/yum/pub", "${basedir}/yum/incoming",
          "${basedir}/apt", "${basedir}/apt/pub", "${basedir}/apt/incoming",
          "${basedir}/gem", "${basedir}/gem/pub", "${basedir}/gem/incoming" ]

  user { $user:
    ensure      => present,
    home        => $basedir,
    uid         => 505,
    gid         => 505,
    managehome  => true,
    system      => true,
    comment     => 'System user for package repositories',
    require     => Group[$group]
  }

  group { $group:
    ensure => present,
    gid => 505,
  }

  file { $dirs:
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0755';
  }

}
