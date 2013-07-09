# Class: repo
#
# Configures a repo system using reprepro for apt, createrepo for yum and
# generate_index for gem.
#
# == Actions
#
# Configures repos and sets up a user and mechanism for uploading packages.
# Repos are reindexed on demand by listeing for write events using incron.
#
# The following set of directories are set up:
#
# $basedir/yum/pub/
#             /incoming/
#         /apt/pub/
#             /incoming/
#         /gem/pub/
#             /incomming/
#
# Each instance of a repo will have one directory under each /incoming/ and
# each /pub/
#
# == Parameters
#
# [*basedir*]
#   Base path of all repositories. Repositories will be created in this path.
#
# [*scriptdir*]
#   The location of the reindex scripts. Default /usr/local/bin
#
# [*user*]
#   Username for user used for uploading new packages.
#
# [*group*]
#   Group set on the folders in $basedir/incoming
#
# [*incoming*]
#   Tells us if we should allow incoming packages to the repo. Default is true
#
# == Examples
#
#  class { "repo": }
#  
# == Resources
#
# http://mirrorer.alioth.debian.org/
#
# == Authors
#
# Christian Bryn <christian.bryn@freecode.no>
# Jan Ivar Beddari <janivar@beddari.net>
# Raymond Kristiansen <raymond.kristiansen@it.uib.no>
#
class repo (
  $basedir = "/var/lib/repo",
  $scriptdir = "/usr/local/bin",
  $user = "upload",
  $group = "upload",
  $incoming = true
) {

  class { 'repo::install': } ->
  class { 'repo::config': } ->
  class { 'repo::service': }

}
