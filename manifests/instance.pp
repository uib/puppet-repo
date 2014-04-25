# Define: repo::instance
#
# Configures a specific apt or yum repo ready to import packages
#
# == Actions
#
# Configures repos and sets up a user and mechanism for uploading packages.
# Repos are reindexed on demand by listeing for write events using incron.
#
# == Parameters
#
# [*version*]
#   Required. Version keyword. For Debian/Ubuntu, this will be a string like
#   "oneiric". For yum set the major release version, like "5" or "6"
# 
# [*repotype*]
#   Required. "apt" or "yum". apt repos are created using reprepro, yum repos
#   using createrepo
#
# [*incoming*]
#   true or false. Enable a incoming directory for this repo. Default true. 
#
# [*arch*]
#   Architecture string to set in the repo config. For yum repos this is
#   typically set to "x86_64", for apt "amd64"
#
# [*description*]
#   Repository description. Defaults to '${name} repository'
#
# [*sign*]
#   Sign the repository with the given key. 'disabled' means no signing and
#   is the default. The gpg given must be generated and available for the root
#   user on the server prior to setting this. As root run "gpg --list-keys"
#
# === Examples
#
#  repo::instance { 'el6-testing':
#    version => '6',
#    repotype => 'yum',
#    arch => "x86_64",
#    require => Class['app::inf::repo']
#  }
#
# == Authors
#
# Christian Bryn <christian.bryn@freecode.no>
# Jan Ivar Beddari <janivar@beddari.net>
# Raymond Kristiansen <raymond.kristiansen@it.uib.no>
#
#
define repo::instance (
  $version,
  $repotype,
  $arch,
  $description="${name} repository",
  $sign = false,
) {
  
  # Validate repo type
  if ! ($repotype in ['apt','yum','gem']) {
    fail "Non-supported repository type"
  }

  File {
    owner => $repo::user,
    group => $repo::group,
    mode  => '0755',
  }

  # Create repo dirs
  $repodir = "${repo::basedir}/${repotype}/pub/${name}"
  $dirs = [ $repodir, "${repo::basedir}/${repotype}/incoming/${name}" ]

  file { $dirs:
    ensure => directory,
  }

  # Incron entry
  file { "/etc/incron.d/${repotype}-${name}":
    ensure  => present,
    owner   => $::repo::user,
    group   => $::repo::group,
    mode    => '0644',
    content => template("${module_name}/incron.d/repo.erb"),
    notify  => Class['repo::service']
  }

  # Apt stuff
  if $repotype == 'apt' {
    file { "${repodir}/conf":
      ensure => directory,
    }
    file { 
      "${repodir}/conf/distributions":
        ensure  => present,
        content => template("${module_name}/apt-distributions.erb");
      "${repodir}/conf/options":
        ensure  => present,
        content => template("${module_name}/apt-options.erb");
    }
  }

  # Gem specific
  # See http://docs.rubygems.org/read/chapter/18
  if $repotype == 'gem' {
    file { "${repodir}/gems":
      ensure => directory,
    }
    exec { "${repodir} gem index":
      command => "/usr/bin/gem generate_index --directory ${repodir}",
      unless  => "/usr/bin/test -d ${repodir}/quick",
      user    => $::repo::user,
      require => File["${repodir}/gems"],
    }
  }

}
