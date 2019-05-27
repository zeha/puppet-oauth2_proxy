# == Class: oauth2_proxy::install
#
# This class should be considered private.
#
class oauth2_proxy::install {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  $tarball = regsubst($::oauth2_proxy::source, '^.*/([^/]+)$', '\1')
  $base    = regsubst($tarball, '(\w+).tar.gz$', '\1')
  $target  = "${::oauth2_proxy::install_root}/${base}/release/oauth2_proxy-linux-amd64"

  include ::archive
  archive { $tarball:
    ensure        => present,
    source        => $::oauth2_proxy::source,
    path          => "${::oauth2_proxy::install_root}/${tarball}",
    extract       => true,
    extract_path  => "${::oauth2_proxy::install_root}/${base}",
    creates       => $target,
    checksum      => $::oauth2_proxy::checksum,
    checksum_type => 'sha1',
    user          => $::oauth2_proxy::user,
    require       => [File[$::oauth2_proxy::install_root], File["${::oauth2_proxy::install_root}/${base}"]],
  }

  file { $::oauth2_proxy::install_root:
    ensure => directory,
    owner  => $::oauth2_proxy::user,
    group  => $::oauth2_proxy::group,
    mode   => '0755',
  }
  file { "${::oauth2_proxy::install_root}/${base}":
    ensure => directory,
    owner  => $::oauth2_proxy::user,
    group  => $::oauth2_proxy::group,
    mode   => '0755',
  }

  file { "${::oauth2_proxy::install_root}/bin":
    ensure => directory,
    owner  => $::oauth2_proxy::user,
    group  => $::oauth2_proxy::group,
    mode   => '0755',
  }

  file { "${::oauth2_proxy::install_root}/bin/oauth2_proxy":
    ensure => link,
    owner  => $::oauth2_proxy::user,
    group  => $::oauth2_proxy::group,
    mode   => '0755',
    target => $target,
  }

  file { '/etc/oauth2_proxy':
    ensure => directory,
    owner  => $::oauth2_proxy::user,
    group  => $::oauth2_proxy::group,
    mode   => '0644',
  }

  file { '/var/log/oauth2_proxy':
    ensure => directory,
    owner  => $::oauth2_proxy::user,
    group  => $::oauth2_proxy::group,
    mode   => '0644'
  }

  case $::oauth2_proxy::provider {
    'systemd': {
      file { "${::oauth2_proxy::systemd_path}/oauth2_proxy@.service":
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template("${module_name}/oauth2_proxy@.service.erb"),
      }
    }
    default: {}
  }
}
