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
  $group      = $::repo::group,
  $user_keys  = $::repo::user_keys
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

  # Add ssh keys for upload users
#  unless empty($ssh_keys) {
  create_resources('repo::add_ssh_keys', $user_keys)
#  }

}

define repo::add_ssh_keys(
  $key,
  $ensure = present,
  $type = 'ssh-rsa',
  $user = $::repo::user
) {

  ssh_authorized_key { "${name}-${user}":
    ensure => $ensure,
    key => $key,
    type => $type,
    user => $user
  }

}
